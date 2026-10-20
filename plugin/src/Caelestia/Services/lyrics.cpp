#include "lyrics.hpp"

#include <qdiriterator.h>
#include <qfileinfo.h>
#include <qjsonarray.h>
#include <qjsondocument.h>
#include <qnetworkcookiejar.h>
#include <qregularexpression.h>
#include <qsavefile.h>
#include <qtextdocumentfragment.h>
#include <qurlquery.h>

#include <algorithm>

#include "config/rootnodes.hpp"
#include "config/serviceconfig.hpp"
#include "config/userpaths.hpp"

namespace {

Q_LOGGING_CATEGORY(lcLyrics, "caelestia.lyrics", QtInfoMsg)

} // namespace

namespace caelestia::services {

using Qt::StringLiterals::operator""_s;
using Qt::StringLiterals::operator""_ba;

namespace {

constexpr int k_loadDebounceMs = 50;
constexpr qreal k_indexFudge = 0.1;

[[nodiscard]] const QHash<QByteArray, QByteArray>& netEaseHeaders() {
    static const QHash<QByteArray, QByteArray> k_h = {
        { "User-Agent"_ba, "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0"_ba },
        { "Referer"_ba, "https://music.163.com/"_ba },
    };
    return k_h;
}

[[nodiscard]] const QHash<QByteArray, QByteArray>& lrclibHeaders() {
    static const QHash<QByteArray, QByteArray> k_h = {
        { "User-Agent"_ba, "caelestia-shell (https://github.com/caelestia-dots/shell)"_ba },
    };
    return k_h;
}

[[nodiscard]] QString joinArtists(const QString& s) {
    return s.trimmed();
}

[[nodiscard]] QString sanitizeFilenamePart(const QString& s) {
    QString out;
    out.reserve(s.size());
    for (const QChar c : s) {
        if (c == u'/' || c == u'\0') {
            out.append(u'_');
        } else {
            out.append(c);
        }
    }
    return out;
}

[[nodiscard]] bool containsCi(const QString& haystack, const QString& needle) {
    return haystack.contains(needle, Qt::CaseInsensitive);
}

[[nodiscard]] const QByteArray& browserUserAgent() {
    static const QByteArray k_ua =
        "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0"_ba;
    return k_ua;
}

[[nodiscard]] const QHash<QByteArray, QByteArray>& kugouHeaders() {
    static const QHash<QByteArray, QByteArray> k_h = {
        { "User-Agent"_ba, browserUserAgent() },
        { "Referer"_ba, "https://www.kugou.com/"_ba },
    };
    return k_h;
}

[[nodiscard]] const QHash<QByteArray, QByteArray>& qqMusicHeaders() {
    static const QHash<QByteArray, QByteArray> k_h = {
        { "User-Agent"_ba, browserUserAgent() },
        { "Referer"_ba, "https://y.qq.com/"_ba },
    };
    return k_h;
}

[[nodiscard]] const QHash<QByteArray, QByteArray>& geniusHeaders() {
    static const QHash<QByteArray, QByteArray> k_h = {
        { "User-Agent"_ba, browserUserAgent() },
        { "X-Requested-With"_ba, "XMLHttpRequest"_ba },
    };
    return k_h;
}

[[nodiscard]] const QHash<QByteArray, QByteArray>& musixmatchHeaders() {
    static const QHash<QByteArray, QByteArray> k_h = {
        { "User-Agent"_ba, browserUserAgent() },
        { "Referer"_ba, "https://www.musixmatch.com/"_ba },
    };
    return k_h;
}

void setEncodedQuery(QUrl& url, const QUrlQuery& query) {
    url.setQuery(query.query(QUrl::FullyEncoded), QUrl::StrictMode);
}

[[nodiscard]] QString htmlToPlainText(const QString& html) {
    return QTextDocumentFragment::fromHtml(html).toPlainText();
}

[[nodiscard]] QString decodeHtmlEntities(QString s) {
    s.replace(u"&nbsp;"_s, u" "_s);
    s.replace(u"&amp;"_s, u"&"_s);
    s.replace(u"&lt;"_s, u"<"_s);
    s.replace(u"&gt;"_s, u">"_s);
    s.replace(u"&quot;"_s, u"\""_s);
    s.replace(u"&apos;"_s, u"'"_s);

    static const QRegularExpression k_numeric(u"&#(x?[0-9A-Fa-f]+);"_s);
    QString out;
    out.reserve(s.size());
    qsizetype last = 0;
    auto it = k_numeric.globalMatch(s);
    while (it.hasNext()) {
        const auto m = it.next();
        out.append(s.mid(last, m.capturedStart() - last));
        const QString num = m.captured(1);
        bool ok = false;
        const uint code = num.startsWith(u'x') ? num.mid(1).toUInt(&ok, 16) : num.toUInt(&ok, 10);
        if (ok && code > 0) {
            out.append(QChar(static_cast<ushort>(code)));
        } else {
            out.append(m.captured(0));
        }
        last = m.capturedEnd();
    }
    out.append(s.mid(last));
    return out;
}

[[nodiscard]] QString slugify(const QString& input) {
    const QString decomposed = input.normalized(QString::NormalizationForm_KD);
    QString stripped;
    stripped.reserve(decomposed.size());
    for (const QChar c : decomposed) {
        const auto category = c.category();
        if (category == QChar::Mark_NonSpacing || category == QChar::Mark_SpacingCombining
            || category == QChar::Mark_Enclosing) {
            continue;
        }
        stripped.append(c);
    }

    QString out;
    out.reserve(stripped.size());
    bool lastDash = false;
    for (const QChar c : stripped) {
        if (c == u'\'' || c == u'’') {
            continue;
        }
        if (c.isLetterOrNumber()) {
            out.append(c.toLower());
            lastDash = false;
        } else if (!lastDash && !out.isEmpty()) {
            out.append(u'-');
            lastDash = true;
        }
    }
    while (out.endsWith(u'-')) {
        out.chop(1);
    }
    return out;
}

[[nodiscard]] QString jsUnescape(const QString& src) {
    QString out;
    out.reserve(src.size());
    for (qsizetype i = 0; i < src.size(); ++i) {
        const QChar c = src.at(i);
        if (c != u'\\' || i + 1 >= src.size()) {
            out.append(c);
            continue;
        }

        const QChar escaped = src.at(++i);
        switch (escaped.unicode()) {
        case u'n':
            out.append(u'\n');
            break;
        case u'r':
            out.append(u'\r');
            break;
        case u't':
            out.append(u'\t');
            break;
        case u'b':
            out.append(u'\b');
            break;
        case u'f':
            out.append(u'\f');
            break;
        case u'v':
            out.append(u'\v');
            break;
        case u'0':
            out.append(QChar(0));
            break;
        case u'x': {
            if (i + 2 < src.size()) {
                bool ok = false;
                const uint code = src.mid(i + 1, 2).toUInt(&ok, 16);
                if (ok) {
                    out.append(QChar(static_cast<ushort>(code)));
                    i += 2;
                    break;
                }
            }
            out.append(escaped);
            break;
        }
        case u'u': {
            if (i + 4 < src.size()) {
                bool ok = false;
                const uint code = src.mid(i + 1, 4).toUInt(&ok, 16);
                if (ok) {
                    out.append(QChar(static_cast<ushort>(code)));
                    i += 4;
                    break;
                }
            }
            out.append(escaped);
            break;
        }
        default:
            out.append(escaped);
            break;
        }
    }
    return out;
}

[[nodiscard]] QString extractFirstLyricsContainer(const QString& html) {
    const QString attr = u"data-lyrics-container=\"true\""_s;
    const qsizetype attrPos = html.indexOf(attr);
    if (attrPos < 0) {
        return {};
    }

    const qsizetype start = html.lastIndexOf(u"<div"_s, attrPos);
    if (start < 0) {
        return {};
    }

    qsizetype pos = html.indexOf(u'>', attrPos);
    if (pos < 0) {
        return {};
    }
    ++pos;

    qsizetype depth = 1;
    while (depth > 0 && pos < html.size()) {
        const qsizetype nextOpen = html.indexOf(u"<div"_s, pos);
        const qsizetype nextClose = html.indexOf(u"</div>"_s, pos);
        if (nextClose < 0) {
            break;
        }
        if (nextOpen >= 0 && nextOpen < nextClose) {
            ++depth;
            const qsizetype endOpen = html.indexOf(u'>', nextOpen);
            if (endOpen < 0) {
                break;
            }
            pos = endOpen + 1;
        } else {
            --depth;
            pos = nextClose + 6;
        }
    }

    return html.mid(start, pos - start);
}

[[nodiscard]] QString extractGeniusLyrics(const QString& html) {
    const QString marker = u"window.__PRELOADED_STATE__ = JSON.parse('"_s;
    const qsizetype markerPos = html.indexOf(marker);
    if (markerPos >= 0) {
        const qsizetype jsonStart = markerPos + marker.size();
        const qsizetype jsonEnd = html.indexOf(u"');"_s, jsonStart);
        if (jsonEnd > jsonStart) {
            const QString jsonText = jsUnescape(html.mid(jsonStart, jsonEnd - jsonStart));
            const QJsonDocument doc = QJsonDocument::fromJson(jsonText.toUtf8());
            const QString bodyHtml = doc.object()
                                         .value(u"songPage"_s)
                                         .toObject()
                                         .value(u"lyricsData"_s)
                                         .toObject()
                                         .value(u"body"_s)
                                         .toObject()
                                         .value(u"html"_s)
                                         .toString();
            if (!bodyHtml.isEmpty()) {
                return htmlToPlainText(bodyHtml);
            }
        }
    }

    const QString container = extractFirstLyricsContainer(html);
    return container.isEmpty() ? QString() : htmlToPlainText(container);
}

[[nodiscard]] QString extractMusixmatchLyrics(const QString& html) {
    static const QRegularExpression k_nextData(
        u"<script id=\"__NEXT_DATA__\" type=\"application/json\">(.*?)</script>"_s,
        QRegularExpression::DotMatchesEverythingOption);
    const auto match = k_nextData.match(html);
    if (!match.hasMatch()) {
        return {};
    }

    const QJsonDocument doc = QJsonDocument::fromJson(match.captured(1).toUtf8());
    const QJsonObject data = doc.object()
                                 .value(u"props"_s)
                                 .toObject()
                                 .value(u"pageProps"_s)
                                 .toObject()
                                 .value(u"data"_s)
                                 .toObject()
                                 .value(u"trackInfo"_s)
                                 .toObject()
                                 .value(u"data"_s)
                                 .toObject();

    const QString body = data.value(u"lyrics"_s).toObject().value(u"body"_s).toString();
    if (!body.isEmpty()) {
        return body;
    }

    QString out;
    const QJsonArray structure = data.value(u"trackStructureList"_s).toArray();
    for (const auto& section : structure) {
        const QJsonArray lines = section.toObject().value(u"lines"_s).toArray();
        for (const auto& line : lines) {
            const QString text = line.toObject().value(u"text"_s).toString();
            if (!text.isEmpty()) {
                out.append(text);
                out.append(u'\n');
            }
        }
    }
    return out;
}

} // namespace

Lyrics::Lyrics(QObject* parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
    , m_loadDebounce(new QTimer(this)) {
    m_loadDebounce->setSingleShot(true);
    m_loadDebounce->setInterval(k_loadDebounceMs);
    QObject::connect(m_loadDebounce, &QTimer::timeout, this, &Lyrics::doLoad);

    const auto* cfg = config::ConfigSingleton::instance();
    const auto* svcCfg = cfg->services();
    const auto* paths = cfg->paths();

    m_preferredBackend = svcCfg->lyricsBackend();

    QObject::connect(
        svcCfg, &config::ServiceConfig::lyricsBackendChanged, this, &Lyrics::onPreferredBackendConfigChanged);
    QObject::connect(paths, &config::UserPaths::lyricsDirChanged, this, &Lyrics::onLyricsDirChanged);

    loadLyricsMap();
}

QStringList Lyrics::lyrics() const {
    return m_lyrics;
}

LyricsBackend Lyrics::backend() const {
    return m_backend;
}

LyricsBackend Lyrics::preferredBackend() const {
    return m_preferredBackend;
}

void Lyrics::setPreferredBackend(LyricsBackend value) {
    if (m_preferredBackend == value) {
        return;
    }
    m_preferredBackend = value;
    emit preferredBackendChanged();

    config::ConfigSingleton::instance()->services()->set_lyricsBackend(value);

    scheduleLoad();
}

QList<LyricCandidate> Lyrics::lyricCandidates() const {
    return m_candidates;
}

LyricCandidate Lyrics::selectedCandidate() const {
    return m_selected;
}

void Lyrics::setSelectedCandidate(const LyricCandidate& value) {
    if (m_selected == value) {
        return;
    }
    m_selected = value;
    emit selectedCandidateChanged();

    if (!value.isValid()) {
        return;
    }

    const auto b = value.backend();
    setBackend(b);
    setLoading(true);

    cancelInFlight();
    const int reqId = newRequestId();

    if (isSyncedBackend(b)) {
        const QString cached = readCachedLrc(b, value.id());
        if (!cached.isEmpty()) {
            const auto lines = parseLrc(cached);
            if (!lines.isEmpty()) {
                setLines(lines, b, true);
                setLoading(false);
                if (!m_settingFromPrefs) {
                    persistTrackPrefs();
                }
                return;
            }
        }
    }

    if (b == LyricsBackend::LRCLIB) {
        fetchLrclibById(value.id(), reqId);
    } else if (b == LyricsBackend::NetEase) {
        fetchNetEaseLyricsById(value.id(), reqId);
    } else if (b == LyricsBackend::Kugou) {
        fetchKugouLyricsById(value.id(), reqId);
    } else if (b == LyricsBackend::QQMusic) {
        fetchQQMusicLyricsById(value.id(), reqId);
    } else if (b == LyricsBackend::Musixmatch) {
        fetchMusixmatchLyricsById(value.id(), reqId);
    } else if (b == LyricsBackend::LyricsOvh) {
        fetchLyricsOvhById(value.id(), reqId);
    } else if (b == LyricsBackend::Genius) {
        fetchGeniusLyricsById(value.id(), reqId);
    } else if (b == LyricsBackend::Local) {
        // For local, the id is the file path. Read directly.
        QFile f(value.id());
        if (f.open(QIODevice::ReadOnly)) {
            const QString text = QString::fromUtf8(f.readAll());
            const auto lrcLines = parseLrc(text);
            const bool synced = !lrcLines.isEmpty();
            const auto lines = synced ? lrcLines : parsePlainLyrics(text, m_duration);
            if (lines.isEmpty()) {
                qCWarning(lcLyrics) << "selectedCandidate: no lyrics in local file" << value.id();
                setLoading(false);
            } else {
                setLines(lines, LyricsBackend::Local, synced);
                setLoading(false);
            }
        } else {
            qCWarning(lcLyrics) << "selectedCandidate: cannot open local file" << value.id();
            setLoading(false);
        }
    } else {
        setLoading(false);
    }

    if (!m_settingFromPrefs) {
        persistTrackPrefs();
    }
}

bool Lyrics::loading() const {
    return m_loading;
}

bool Lyrics::hasLyrics() const {
    return m_hasLyrics;
}

bool Lyrics::synced() const {
    return m_synced;
}

qreal Lyrics::offset() const {
    return m_offset;
}

void Lyrics::setOffset(qreal value) {
    if (qFuzzyCompare(m_offset, value)) {
        return;
    }
    m_offset = value;
    emit offsetChanged();

    if (!m_settingFromPrefs) {
        persistTrackPrefs();
    }
}

QString Lyrics::trackArtist() const {
    return m_artist;
}

QString Lyrics::trackTitle() const {
    return m_title;
}

int Lyrics::indexForTime(qreal time) const {
    if (m_lines.isEmpty()) {
        return -1;
    }
    const qreal target = time - m_offset + k_indexFudge;
    qsizetype lo = 0;
    qsizetype hi = m_lines.size();
    while (lo < hi) {
        const qsizetype mid = lo + (hi - lo) / 2;
        if (m_lines.at(mid).time <= target) {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }
    return static_cast<int>(lo - 1);
}

qreal Lyrics::timeForIndex(int index) const {
    if (index < 0 || index >= m_lines.size()) {
        return -1.0;
    }
    return m_lines.at(index).time + m_offset;
}

void Lyrics::setTrack(const QString& artist, const QString& title, const QString& album, qreal duration) {
    const QString a = artist.trimmed();
    const QString t = title.trimmed();

    if (a == m_artist && t == m_title && album == m_album && qFuzzyCompare(duration + 1.0, m_duration + 1.0)) {
        return;
    }

    m_artist = a;
    m_title = t;
    m_album = album;
    m_duration = duration;
    emit trackChanged();

    scheduleLoad();
}

void Lyrics::clearTrack() {
    cancelInFlight();
    m_artist.clear();
    m_title.clear();
    m_album.clear();
    m_duration = 0.0;
    emit trackChanged();

    clearCandidates();
    clearLines();
    setLoading(false);
}

void Lyrics::refresh() {
    scheduleLoad();
}

void Lyrics::setBackend(LyricsBackend value) {
    if (m_backend == value) {
        return;
    }
    m_backend = value;
    emit backendChanged();
}

void Lyrics::setLoading(bool value) {
    if (m_loading == value) {
        return;
    }
    m_loading = value;
    emit loadingChanged();
}

void Lyrics::setLines(QVector<LyricLine> lines, LyricsBackend source, bool synced) {
    std::ranges::sort(lines, [](const LyricLine& a, const LyricLine& b) {
        return a.time < b.time;
    });

    m_lines = std::move(lines);
    QStringList list;
    list.reserve(m_lines.size());
    for (const auto& l : std::as_const(m_lines)) {
        list.append(l.text);
    }
    m_lyrics = std::move(list);

    setBackend(source);
    emit lyricsChanged();

    if (m_synced != synced) {
        m_synced = synced;
        emit syncedChanged();
    }

    const auto hasLyrics = !m_lines.isEmpty();
    if (hasLyrics != m_hasLyrics) {
        m_hasLyrics = hasLyrics;
        emit hasLyricsChanged();
    }
}

void Lyrics::clearLines() {
    if (!m_hasLyrics) {
        return;
    }

    // Doesn't actually clear lines, set a flag instead so anims can run
    m_hasLyrics = false;
    emit hasLyricsChanged();
}

void Lyrics::appendCandidates(const QList<LyricCandidate>& add) {
    if (add.isEmpty()) {
        return;
    }
    bool changed = false;
    for (const auto& c : add) {
        if (!m_candidates.contains(c)) {
            m_candidates.append(c);
            changed = true;
        }
    }
    if (changed) {
        emit lyricCandidatesChanged();
    }
}

void Lyrics::clearCandidates() {
    if (m_candidates.isEmpty()) {
        return;
    }
    m_candidates.clear();
    emit lyricCandidatesChanged();
}

void Lyrics::scheduleLoad() {
    m_loadDebounce->start();
}

int Lyrics::newRequestId() {
    return ++m_currentRequestId;
}

void Lyrics::cancelInFlight() {
    for (auto it = m_pendingReplies.begin(); it != m_pendingReplies.end(); ++it) {
        const auto& replies = it.value();
        for (const auto& ptr : replies) {
            if (auto* const reply = ptr.data()) {
                reply->abort();
                reply->deleteLater();
            }
        }
    }
    m_pendingReplies.clear();
}

void Lyrics::trackReply(int reqId, QNetworkReply* reply) {
    if (!reply) {
        return;
    }
    m_pendingReplies[reqId].append(QPointer<QNetworkReply>(reply));
}

void Lyrics::doLoad() {
    if (m_artist.isEmpty() && m_title.isEmpty()) {
        clearLines();
        clearCandidates();
        setLoading(false);
        return;
    }

    cancelInFlight();
    const int reqId = newRequestId();

    setLoading(true);
    clearLines();
    clearCandidates();

    // Restore per-track prefs (offset, last-selected backend/id)
    m_settingFromPrefs = true;
    const QJsonObject saved = m_lyricsMap.value(trackKey()).toObject();
    setOffset(saved.value(u"offset"_s).toDouble(0.0));
    LyricCandidate restored;
    const QString savedBackendKey = saved.value(u"backend"_s).toString();
    const QString savedId = saved.value(u"id"_s).toString();
    if (!savedBackendKey.isEmpty() && !savedId.isEmpty()) {
        restored = LyricCandidate(backendFromKey(savedBackendKey), savedId, m_title, m_artist, m_album, m_duration);
    }
    m_settingFromPrefs = false;

    // Always populate online candidates for the picker, regardless of preferred backend
    searchLrclibCandidates(reqId);
    searchNetEaseCandidates(reqId);
    searchKugouCandidates(reqId);
    searchQQMusicCandidates(reqId);
    searchMusixmatchCandidates(reqId);
    searchLyricsOvhCandidates(reqId);
    searchGeniusCandidates(reqId);

    if (restored.isValid()) {
        // Honor saved selection for this track
        m_settingFromPrefs = true;
        setSelectedCandidate(restored);
        m_settingFromPrefs = false;
        return;
    }

    // Primary attempt by preferred backend
    switch (m_preferredBackend) {
    case LyricsBackend::Local:
        tryLocal(reqId);
        break;
    case LyricsBackend::LRCLIB:
        tryLrclib(reqId);
        break;
    case LyricsBackend::NetEase:
        tryNetEase(reqId);
        break;
    case LyricsBackend::Kugou:
        tryKugou(reqId);
        break;
    case LyricsBackend::QQMusic:
        tryQQMusic(reqId);
        break;
    case LyricsBackend::Musixmatch:
        tryMusixmatch(reqId);
        break;
    case LyricsBackend::LyricsOvh:
        tryLyricsOvh(reqId);
        break;
    case LyricsBackend::Genius:
        tryGenius(reqId);
        break;
    case LyricsBackend::Auto:
    default:
        tryLocal(reqId);
        break;
    }
}

void Lyrics::chainNext(LyricsBackend justFailed, int reqId) {
    if (m_preferredBackend != LyricsBackend::Auto) {
        // Non-auto modes don't chain
        setLoading(false);
        return;
    }
    switch (justFailed) {
    case LyricsBackend::Local:
        tryLrclib(reqId);
        return;
    case LyricsBackend::LRCLIB:
        tryNetEase(reqId);
        return;
    case LyricsBackend::NetEase:
        tryKugou(reqId);
        return;
    case LyricsBackend::Kugou:
        tryQQMusic(reqId);
        return;
    case LyricsBackend::QQMusic:
        tryMusixmatch(reqId);
        return;
    case LyricsBackend::Musixmatch:
        tryLyricsOvh(reqId);
        return;
    case LyricsBackend::LyricsOvh:
        tryGenius(reqId);
        return;
    case LyricsBackend::Genius:
    default:
        setLoading(false);
        return;
    }
}

bool Lyrics::matchesTrack(const QString& title, const QString& artist) const {
    if (!m_title.isEmpty() && !containsCi(title, m_title) && !containsCi(m_title, title)) {
        return false;
    }
    if (!m_artist.isEmpty() && !artist.isEmpty() && !containsCi(artist, m_artist)
        && !containsCi(m_artist, artist)) {
        return false;
    }
    return true;
}

bool Lyrics::isSyncedBackend(LyricsBackend value) {
    switch (value) {
    case LyricsBackend::Local:
    case LyricsBackend::LRCLIB:
    case LyricsBackend::NetEase:
    case LyricsBackend::Kugou:
    case LyricsBackend::QQMusic:
        return true;
    case LyricsBackend::Auto:
    case LyricsBackend::Musixmatch:
    case LyricsBackend::LyricsOvh:
    case LyricsBackend::Genius:
    default:
        return false;
    }
}

void Lyrics::tryLocal(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::Local);

    const QString dir = lyricsDir();
    if (dir.isEmpty()) {
        chainNext(LyricsBackend::Local, reqId);
        return;
    }

    const QString direct = tryReadLocalLrc(dir, m_artist, m_title);
    if (!direct.isEmpty()) {
        QFile f(direct);
        if (f.open(QIODevice::ReadOnly)) {
            const QString text = QString::fromUtf8(f.readAll());
            const auto lrcLines = parseLrc(text);
            const bool synced = !lrcLines.isEmpty();
            const auto lines = synced ? lrcLines : parsePlainLyrics(text, m_duration);
            if (!lines.isEmpty()) {
                setLines(lines, LyricsBackend::Local, synced);
                appendCandidates(
                    { LyricCandidate(LyricsBackend::Local, direct, m_title, m_artist, m_album, m_duration) });
                m_selected = LyricCandidate(LyricsBackend::Local, direct, m_title, m_artist, m_album, m_duration);
                emit selectedCandidateChanged();
                if (!m_settingFromPrefs) {
                    persistTrackPrefs();
                }
                setLoading(false);
                return;
            }
        }
    }

    const QString recursive = findLocalLrcRecursive(dir, m_artist, m_title);
    if (!recursive.isEmpty()) {
        QFile f(recursive);
        if (f.open(QIODevice::ReadOnly)) {
            const QString text = QString::fromUtf8(f.readAll());
            const auto lrcLines = parseLrc(text);
            const bool synced = !lrcLines.isEmpty();
            const auto lines = synced ? lrcLines : parsePlainLyrics(text, m_duration);
            if (!lines.isEmpty()) {
                setLines(lines, LyricsBackend::Local, synced);
                appendCandidates(
                    { LyricCandidate(LyricsBackend::Local, recursive, m_title, m_artist, m_album, m_duration) });
                m_selected = LyricCandidate(LyricsBackend::Local, recursive, m_title, m_artist, m_album, m_duration);
                emit selectedCandidateChanged();
                if (!m_settingFromPrefs) {
                    persistTrackPrefs();
                }
                setLoading(false);
                return;
            }
        }
    }

    qCDebug(lcLyrics) << "no local lrc for" << m_artist << "-" << m_title;
    chainNext(LyricsBackend::Local, reqId);
}

void Lyrics::tryLrclib(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::LRCLIB);

    QUrl url(u"https://lrclib.net/api/get"_s);
    QUrlQuery q;
    q.addQueryItem(u"track_name"_s, m_title);
    q.addQueryItem(u"artist_name"_s, m_artist);
    if (!m_album.isEmpty()) {
        q.addQueryItem(u"album_name"_s, m_album);
    }

    constexpr qreal k_maxDurationSecs = std::numeric_limits<int>::max();
    if (m_duration > 0 && qIsFinite(m_duration) && m_duration < k_maxDurationSecs) {
        q.addQueryItem(u"duration"_s, QString::number(qRound(m_duration)));
    }
    setEncodedQuery(url, q);

    auto* reply = getJson(url, lrclibHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "lrclib /get error:" << reply->errorString();
            chainNext(LyricsBackend::LRCLIB, reqId);
            return;
        }
        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonObject obj = doc.object();
        const QString synced = obj.value(u"syncedLyrics"_s).toString();
        const QString plain = obj.value(u"plainLyrics"_s).toString();
        const qint64 id = static_cast<qint64>(obj.value(u"id"_s).toDouble());

        if (synced.isEmpty() && plain.isEmpty()) {
            qCDebug(lcLyrics) << "lrclib: no lyrics for" << m_artist << "-" << m_title;
            chainNext(LyricsBackend::LRCLIB, reqId);
            return;
        }

        const auto lines = synced.isEmpty() ? parsePlainLyrics(plain, m_duration) : parseLrc(synced);
        if (lines.isEmpty()) {
            chainNext(LyricsBackend::LRCLIB, reqId);
            return;
        }

        if (!synced.isEmpty()) {
            writeCachedLrc(LyricsBackend::LRCLIB, QString::number(id), synced);
        }
        setLines(lines, LyricsBackend::LRCLIB, !synced.isEmpty());
        const LyricCandidate cand(LyricsBackend::LRCLIB, QString::number(id), obj.value(u"trackName"_s).toString(),
            obj.value(u"artistName"_s).toString(), obj.value(u"albumName"_s).toString(),
            obj.value(u"duration"_s).toDouble());
        appendCandidates({ cand });
        m_selected = cand;
        emit selectedCandidateChanged();
        if (!m_settingFromPrefs) {
            persistTrackPrefs();
        }
        setLoading(false);
    });
}

void Lyrics::tryNetEase(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::NetEase);

    // Reset cookies (LyricsBackend::NetEase rejects requests with stale cookies sometimes)
    m_nam->setCookieJar(new QNetworkCookieJar(m_nam));

    QUrl url(u"https://music.163.com/api/search/get"_s);
    QUrlQuery q;
    q.addQueryItem(u"s"_s, u"%1 %2"_s.arg(m_title, m_artist));
    q.addQueryItem(u"type"_s, u"1"_s);
    q.addQueryItem(u"limit"_s, u"5"_s);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, netEaseHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "netease /search error:" << reply->errorString();
            chainNext(LyricsBackend::NetEase, reqId);
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray songs = doc.object().value(u"result"_s).toObject().value(u"songs"_s).toArray();

        // Find best match by artist substring
        qint64 bestId = -1;
        for (const auto& v : songs) {
            const QJsonObject s = v.toObject();
            const QJsonArray artists = s.value(u"artists"_s).toArray();
            if (artists.isEmpty()) {
                continue;
            }
            const QString sArtist = artists.first().toObject().value(u"name"_s).toString();
            if (containsCi(m_artist, sArtist) || containsCi(sArtist, m_artist)) {
                bestId = static_cast<qint64>(s.value(u"id"_s).toDouble());
                break;
            }
        }

        if (bestId < 0) {
            qCDebug(lcLyrics) << "netease: no artist match for" << m_artist << "-" << m_title;
            chainNext(LyricsBackend::NetEase, reqId);
            return;
        }

        fetchNetEaseLyricsById(QString::number(bestId), reqId);
    });
}

void Lyrics::tryKugou(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::Kugou);

    QUrl url(u"https://krcs.kugou.com/search"_s);
    QUrlQuery q;
    q.addQueryItem(u"ver"_s, u"1"_s);
    q.addQueryItem(u"man"_s, u"yes"_s);
    q.addQueryItem(u"client"_s, u"mobi"_s);
    q.addQueryItem(
        u"keyword"_s, m_artist.isEmpty() ? m_title : u"%1 - %2"_s.arg(m_artist, m_title));
    setEncodedQuery(url, q);

    auto* reply = getJson(url, kugouHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "kugou lyrics search error:" << reply->errorString();
            chainNext(LyricsBackend::Kugou, reqId);
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray candidates = doc.object().value(u"candidates"_s).toArray();
        if (candidates.isEmpty()) {
            chainNext(LyricsBackend::Kugou, reqId);
            return;
        }

        QJsonObject best;
        for (const auto& value : candidates) {
            const QJsonObject candidate = value.toObject();
            if (matchesTrack(candidate.value(u"song"_s).toString(), candidate.value(u"singer"_s).toString())) {
                best = candidate;
                break;
            }
        }
        if (best.isEmpty()) {
            best = candidates.first().toObject();
        }

        const QString lyricsId = best.value(u"id"_s).toString();
        const QString accessKey = best.value(u"accesskey"_s).toString();
        if (lyricsId.isEmpty() || accessKey.isEmpty()) {
            chainNext(LyricsBackend::Kugou, reqId);
            return;
        }

        fetchKugouLyricsById(u"%1|%2"_s.arg(lyricsId, accessKey), reqId);
    });
}

void Lyrics::tryQQMusic(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::QQMusic);

    QUrl url(u"https://c.y.qq.com/soso/fcgi-bin/client_search_cp"_s);
    QUrlQuery q;
    q.addQueryItem(u"p"_s, u"1"_s);
    q.addQueryItem(u"n"_s, u"5"_s);
    q.addQueryItem(u"w"_s, u"%1 %2"_s.arg(m_artist, m_title).trimmed());
    q.addQueryItem(u"format"_s, u"json"_s);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, qqMusicHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "qq music search error:" << reply->errorString();
            chainNext(LyricsBackend::QQMusic, reqId);
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray songs =
            doc.object().value(u"data"_s).toObject().value(u"song"_s).toObject().value(u"list"_s).toArray();
        if (songs.isEmpty()) {
            chainNext(LyricsBackend::QQMusic, reqId);
            return;
        }

        QJsonObject best;
        for (const auto& value : songs) {
            const QJsonObject song = value.toObject();
            QStringList artists;
            const QJsonArray singer = song.value(u"singer"_s).toArray();
            artists.reserve(singer.size());
            for (const auto& a : singer) {
                artists.append(a.toObject().value(u"name"_s).toString());
            }
            if (matchesTrack(song.value(u"songname"_s).toString(), artists.join(u", "_s))) {
                best = song;
                break;
            }
        }
        if (best.isEmpty()) {
            best = songs.first().toObject();
        }

        const QString songmid = best.value(u"songmid"_s).toString();
        if (songmid.isEmpty()) {
            chainNext(LyricsBackend::QQMusic, reqId);
            return;
        }

        fetchQQMusicLyricsById(songmid, reqId);
    });
}

void Lyrics::tryMusixmatch(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::Musixmatch);

    const QString artistSlug = slugify(m_artist);
    const QString titleSlug = slugify(m_title);
    if (artistSlug.isEmpty() || titleSlug.isEmpty()) {
        chainNext(LyricsBackend::Musixmatch, reqId);
        return;
    }

    const QUrl url(u"https://www.musixmatch.com/lyrics/%1/%2"_s.arg(artistSlug, titleSlug));
    fetchMusixmatchLyricsById(url.toString(), reqId);
}

void Lyrics::tryLyricsOvh(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::LyricsOvh);

    if (m_title.isEmpty()) {
        chainNext(LyricsBackend::LyricsOvh, reqId);
        return;
    }

    const QString artist = m_artist.isEmpty() ? u"Unknown"_s : m_artist;
    const QUrl url(u"https://api.lyrics.ovh/v1/%1/%2"_s.arg(
        QString::fromLatin1(QUrl::toPercentEncoding(artist)),
        QString::fromLatin1(QUrl::toPercentEncoding(m_title))));
    fetchLyricsOvhById(url.toString(), reqId);
}

void Lyrics::tryGenius(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }

    setBackend(LyricsBackend::Genius);

    QUrl url(u"https://genius.com/api/search/multi"_s);
    QUrlQuery q;
    q.addQueryItem(u"q"_s, u"%1 %2"_s.arg(m_artist, m_title).trimmed());
    setEncodedQuery(url, q);

    auto* reply = getJson(url, geniusHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }

        QString bestUrl;
        if (reply->error() == QNetworkReply::NoError) {
            const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            const QJsonArray sections = doc.object().value(u"response"_s).toObject().value(u"sections"_s).toArray();
            QString firstUrl;
            for (const auto& sectionValue : sections) {
                const QJsonArray hits = sectionValue.toObject().value(u"hits"_s).toArray();
                for (const auto& hitValue : hits) {
                    const QJsonObject result = hitValue.toObject().value(u"result"_s).toObject();
                    if (result.value(u"_type"_s).toString() != u"song"_s) {
                        continue;
                    }
                    const QString resultUrl = result.value(u"url"_s).toString();
                    if (resultUrl.isEmpty()) {
                        continue;
                    }
                    if (firstUrl.isEmpty()) {
                        firstUrl = resultUrl;
                    }
                    if (matchesTrack(result.value(u"title"_s).toString(),
                            result.value(u"primary_artist_names"_s).toString())) {
                        bestUrl = resultUrl;
                        break;
                    }
                }
                if (!bestUrl.isEmpty()) {
                    break;
                }
            }
            if (bestUrl.isEmpty()) {
                bestUrl = firstUrl;
            }
        } else {
            qCDebug(lcLyrics) << "genius search error:" << reply->errorString();
        }

        if (bestUrl.isEmpty()) {
            const QString artistSlug = slugify(m_artist);
            const QString titleSlug = slugify(m_title);
            if (!titleSlug.isEmpty()) {
                bestUrl = artistSlug.isEmpty()
                    ? u"https://genius.com/%1-lyrics"_s.arg(titleSlug)
                    : u"https://genius.com/%1-%2-lyrics"_s.arg(artistSlug, titleSlug);
            }
        }

        if (bestUrl.isEmpty()) {
            chainNext(LyricsBackend::Genius, reqId);
            return;
        }

        fetchGeniusLyricsById(bestUrl, reqId);
    });
}

void Lyrics::searchLrclibCandidates(int reqId) {
    QUrl url(u"https://lrclib.net/api/search"_s);
    QUrlQuery q;
    q.addQueryItem(u"track_name"_s, m_title);
    q.addQueryItem(u"artist_name"_s, m_artist);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, lrclibHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "lrclib /search error:" << reply->errorString();
            return;
        }
        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray arr = doc.array();

        QList<LyricCandidate> add;
        add.reserve(arr.size());
        for (const auto& v : arr) {
            const QJsonObject o = v.toObject();
            if (o.value(u"syncedLyrics"_s).isNull() && o.value(u"plainLyrics"_s).isNull()) {
                continue;
            }
            add.append(
                LyricCandidate(LyricsBackend::LRCLIB, QString::number(static_cast<qint64>(o.value(u"id"_s).toDouble())),
                    o.value(u"trackName"_s).toString(), o.value(u"artistName"_s).toString(),
                    o.value(u"albumName"_s).toString(), o.value(u"duration"_s).toDouble()));
        }
        appendCandidates(add);
    });
}

void Lyrics::searchNetEaseCandidates(int reqId) {
    m_nam->setCookieJar(new QNetworkCookieJar(m_nam));

    QUrl url(u"https://music.163.com/api/search/get"_s);
    QUrlQuery q;
    q.addQueryItem(u"s"_s, u"%1 %2"_s.arg(m_title, m_artist));
    q.addQueryItem(u"type"_s, u"1"_s);
    q.addQueryItem(u"limit"_s, u"5"_s);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, netEaseHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "netease candidates error:" << reply->errorString();
            return;
        }
        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray songs = doc.object().value(u"result"_s).toObject().value(u"songs"_s).toArray();

        QList<LyricCandidate> add;
        add.reserve(songs.size());
        for (const auto& v : songs) {
            const QJsonObject s = v.toObject();
            QStringList artistNames;
            const QJsonArray artists = s.value(u"artists"_s).toArray();
            artistNames.reserve(artists.size());
            for (const auto& a : artists) {
                artistNames.append(a.toObject().value(u"name"_s).toString());
            }
            add.append(LyricCandidate(LyricsBackend::NetEase,
                QString::number(static_cast<qint64>(s.value(u"id"_s).toDouble())), s.value(u"name"_s).toString(),
                artistNames.join(u", "_s)));
        }
        appendCandidates(add);
    });
}

void Lyrics::searchKugouCandidates(int reqId) {
    QUrl url(u"https://krcs.kugou.com/search"_s);
    QUrlQuery q;
    q.addQueryItem(u"ver"_s, u"1"_s);
    q.addQueryItem(u"man"_s, u"yes"_s);
    q.addQueryItem(u"client"_s, u"mobi"_s);
    q.addQueryItem(
        u"keyword"_s, m_artist.isEmpty() ? m_title : u"%1 - %2"_s.arg(m_artist, m_title));
    setEncodedQuery(url, q);

    auto* reply = getJson(url, kugouHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "kugou candidates error:" << reply->errorString();
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray candidates = doc.object().value(u"candidates"_s).toArray();

        QList<LyricCandidate> add;
        add.reserve(candidates.size());
        for (const auto& value : candidates) {
            const QJsonObject candidate = value.toObject();
            const QString lyricsId = candidate.value(u"id"_s).toString();
            const QString accessKey = candidate.value(u"accesskey"_s).toString();
            if (lyricsId.isEmpty() || accessKey.isEmpty()) {
                continue;
            }
            add.append(LyricCandidate(LyricsBackend::Kugou,
                u"%1|%2"_s.arg(lyricsId, accessKey), candidate.value(u"song"_s).toString(),
                candidate.value(u"singer"_s).toString(), {}, candidate.value(u"duration"_s).toDouble() / 1000.0));
            if (add.size() >= 5) {
                break;
            }
        }
        appendCandidates(add);
    });
}

void Lyrics::searchQQMusicCandidates(int reqId) {
    QUrl url(u"https://c.y.qq.com/soso/fcgi-bin/client_search_cp"_s);
    QUrlQuery q;
    q.addQueryItem(u"p"_s, u"1"_s);
    q.addQueryItem(u"n"_s, u"5"_s);
    q.addQueryItem(u"w"_s, u"%1 %2"_s.arg(m_artist, m_title).trimmed());
    q.addQueryItem(u"format"_s, u"json"_s);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, qqMusicHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "qq music candidates error:" << reply->errorString();
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray songs =
            doc.object().value(u"data"_s).toObject().value(u"song"_s).toObject().value(u"list"_s).toArray();

        QList<LyricCandidate> add;
        add.reserve(songs.size());
        for (const auto& value : songs) {
            const QJsonObject song = value.toObject();
            const QString songmid = song.value(u"songmid"_s).toString();
            if (songmid.isEmpty()) {
                continue;
            }
            QStringList artists;
            const QJsonArray singer = song.value(u"singer"_s).toArray();
            artists.reserve(singer.size());
            for (const auto& a : singer) {
                artists.append(a.toObject().value(u"name"_s).toString());
            }
            add.append(LyricCandidate(LyricsBackend::QQMusic, songmid, song.value(u"songname"_s).toString(),
                artists.join(u", "_s), song.value(u"albumname"_s).toString(),
                song.value(u"interval"_s).toDouble()));
        }
        appendCandidates(add);
    });
}

void Lyrics::searchMusixmatchCandidates(int reqId) {
    if (reqId != m_currentRequestId) {
        return;
    }
    const QString artistSlug = slugify(m_artist);
    const QString titleSlug = slugify(m_title);
    if (artistSlug.isEmpty() || titleSlug.isEmpty()) {
        return;
    }
    const QUrl url(u"https://www.musixmatch.com/lyrics/%1/%2"_s.arg(artistSlug, titleSlug));
    appendCandidates(
        { LyricCandidate(LyricsBackend::Musixmatch, url.toString(), m_title, m_artist, m_album, m_duration) });
}

void Lyrics::searchLyricsOvhCandidates(int reqId) {
    QUrl url(u"https://api.lyrics.ovh/suggest/%1"_s.arg(
        QString::fromLatin1(QUrl::toPercentEncoding(u"%1 %2"_s.arg(m_artist, m_title).trimmed()))));
    auto* reply = getJson(url);
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }

        QList<LyricCandidate> add;
        if (reply->error() == QNetworkReply::NoError) {
            const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            const QJsonArray data = doc.object().value(u"data"_s).toArray();
            add.reserve(data.size());
            for (const auto& value : data) {
                const QJsonObject item = value.toObject();
                const QString title = item.value(u"title"_s).toString();
                const QString artist = item.value(u"artist"_s).toObject().value(u"name"_s).toString();
                if (title.isEmpty() || artist.isEmpty()) {
                    continue;
                }
                const QUrl itemUrl(u"https://api.lyrics.ovh/v1/%1/%2"_s.arg(
                    QString::fromLatin1(QUrl::toPercentEncoding(artist)),
                    QString::fromLatin1(QUrl::toPercentEncoding(title))));
                add.append(LyricCandidate(LyricsBackend::LyricsOvh, itemUrl.toString(), title, artist,
                    item.value(u"album"_s).toObject().value(u"title"_s).toString(),
                    item.value(u"duration"_s).toDouble()));
            }
        }

        if (add.isEmpty() && !m_title.isEmpty()) {
            const QString artist = m_artist.isEmpty() ? u"Unknown"_s : m_artist;
            const QUrl itemUrl(u"https://api.lyrics.ovh/v1/%1/%2"_s.arg(
                QString::fromLatin1(QUrl::toPercentEncoding(artist)),
                QString::fromLatin1(QUrl::toPercentEncoding(m_title))));
            add.append(LyricCandidate(
                LyricsBackend::LyricsOvh, itemUrl.toString(), m_title, m_artist, m_album, m_duration));
        }
        appendCandidates(add);
    });
}

void Lyrics::searchGeniusCandidates(int reqId) {
    QUrl url(u"https://genius.com/api/search/multi"_s);
    QUrlQuery q;
    q.addQueryItem(u"q"_s, u"%1 %2"_s.arg(m_artist, m_title).trimmed());
    setEncodedQuery(url, q);

    auto* reply = getJson(url, geniusHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "genius candidates error:" << reply->errorString();
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QJsonArray sections = doc.object().value(u"response"_s).toObject().value(u"sections"_s).toArray();

        QList<LyricCandidate> add;
        for (const auto& sectionValue : sections) {
            const QJsonArray hits = sectionValue.toObject().value(u"hits"_s).toArray();
            for (const auto& hitValue : hits) {
                const QJsonObject result = hitValue.toObject().value(u"result"_s).toObject();
                if (result.value(u"_type"_s).toString() != u"song"_s) {
                    continue;
                }
                const QString resultUrl = result.value(u"url"_s).toString();
                if (resultUrl.isEmpty()) {
                    continue;
                }
                add.append(LyricCandidate(LyricsBackend::Genius, resultUrl,
                    result.value(u"title"_s).toString(), result.value(u"primary_artist_names"_s).toString(),
                    result.value(u"album"_s).toObject().value(u"name"_s).toString(),
                    result.value(u"duration"_s).toDouble()));
                if (add.size() >= 5) {
                    break;
                }
            }
            if (add.size() >= 5) {
                break;
            }
        }
        appendCandidates(add);
    });
}

void Lyrics::fetchLrclibById(const QString& id, int reqId) {
    const QUrl url(u"https://lrclib.net/api/get/"_s + id);
    auto* reply = getJson(url, lrclibHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId, id] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCWarning(lcLyrics) << "lrclib /get/{id} error:" << reply->errorString();
            setLoading(false);
            return;
        }
        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QString synced = doc.object().value(u"syncedLyrics"_s).toString();
        const QString plain = doc.object().value(u"plainLyrics"_s).toString();
        if (synced.isEmpty() && plain.isEmpty()) {
            qCDebug(lcLyrics) << "lrclib /get/{id}: no lyrics";
            setLoading(false);
            return;
        }
        if (!synced.isEmpty()) {
            writeCachedLrc(LyricsBackend::LRCLIB, id, synced);
        }
        const auto lines = synced.isEmpty() ? parsePlainLyrics(plain, m_duration) : parseLrc(synced);
        setLines(lines, LyricsBackend::LRCLIB, !synced.isEmpty());
        setLoading(false);
    });
}

void Lyrics::fetchNetEaseLyricsById(const QString& id, int reqId) {
    QUrl url(u"https://music.163.com/api/song/lyric"_s);
    QUrlQuery q;
    q.addQueryItem(u"id"_s, id);
    q.addQueryItem(u"lv"_s, u"1"_s);
    q.addQueryItem(u"kv"_s, u"1"_s);
    q.addQueryItem(u"tv"_s, u"-1"_s);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, netEaseHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId, id] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCWarning(lcLyrics) << "netease /lyric error:" << reply->errorString();
            setLoading(false);
            return;
        }
        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QString lrc = doc.object().value(u"lrc"_s).toObject().value(u"lyric"_s).toString();
        if (lrc.isEmpty()) {
            qCDebug(lcLyrics) << "netease /lyric: empty for id" << id;
            setLoading(false);
            return;
        }
        writeCachedLrc(LyricsBackend::NetEase, id, lrc);
        setLines(parseLrc(lrc), LyricsBackend::NetEase);
        setLoading(false);
    });
}

void Lyrics::fetchKugouLyricsById(const QString& id, int reqId) {
    const QStringList parts = id.split(u'|');
    if (parts.size() < 2 || parts.value(0).isEmpty() || parts.value(1).isEmpty()) {
        chainNext(LyricsBackend::Kugou, reqId);
        return;
    }

    const QString first = parts.value(0);
    const QString second = parts.value(1);

    const auto startDownload = [this, reqId, id](const QString& lyricsId, const QString& accessKey) {
        if (lyricsId.isEmpty() || accessKey.isEmpty()) {
            chainNext(LyricsBackend::Kugou, reqId);
            return;
        }

        QUrl downloadUrl(u"https://lyrics.kugou.com/download"_s);
        QUrlQuery downloadQuery;
        downloadQuery.addQueryItem(u"ver"_s, u"1"_s);
        downloadQuery.addQueryItem(u"client"_s, u"pc"_s);
        downloadQuery.addQueryItem(u"id"_s, lyricsId);
        downloadQuery.addQueryItem(u"accesskey"_s, accessKey);
        downloadQuery.addQueryItem(u"fmt"_s, u"lrc"_s);
        downloadQuery.addQueryItem(u"charset"_s, u"utf8"_s);
        setEncodedQuery(downloadUrl, downloadQuery);

        auto* downloadReply = getJson(downloadUrl, kugouHeaders());
        trackReply(reqId, downloadReply);

        QObject::connect(downloadReply, &QNetworkReply::finished, this, [this, downloadReply, reqId, id] {
            downloadReply->deleteLater();
            if (reqId != m_currentRequestId) {
                return;
            }
            if (downloadReply->error() != QNetworkReply::NoError) {
                qCDebug(lcLyrics) << "kugou lyrics download error:" << downloadReply->errorString();
                chainNext(LyricsBackend::Kugou, reqId);
                return;
            }

            const QJsonDocument downloadDoc = QJsonDocument::fromJson(downloadReply->readAll());
            const QString encoded = downloadDoc.object().value(u"content"_s).toString();
            if (encoded.isEmpty()) {
                chainNext(LyricsBackend::Kugou, reqId);
                return;
            }

            QString text = QString::fromUtf8(QByteArray::fromBase64(encoded.toUtf8()));
            text.remove(QChar(0xFEFF));
            const auto lines = parseLrc(text);
            if (lines.isEmpty()) {
                chainNext(LyricsBackend::Kugou, reqId);
                return;
            }

            writeCachedLrc(LyricsBackend::Kugou, id, text);
            setLines(lines, LyricsBackend::Kugou, true);
            const LyricCandidate cand(
                LyricsBackend::Kugou, id, m_title, m_artist, m_album, m_duration);
            appendCandidates({ cand });
            m_selected = cand;
            emit selectedCandidateChanged();
            if (!m_settingFromPrefs) {
                persistTrackPrefs();
            }
            setLoading(false);
        });
    };

    bool secondIsDuration = false;
    second.toLongLong(&secondIsDuration);
    if (!secondIsDuration) {
        startDownload(first, second);
        return;
    }

    // Backwards compatibility for saved candidates using "<file hash>|<duration>".
    QUrl searchUrl(u"https://krcs.kugou.com/search"_s);
    QUrlQuery searchQuery;
    searchQuery.addQueryItem(u"ver"_s, u"1"_s);
    searchQuery.addQueryItem(u"man"_s, u"yes"_s);
    searchQuery.addQueryItem(u"client"_s, u"mobi"_s);
    searchQuery.addQueryItem(u"keyword"_s, m_artist.isEmpty() ? m_title : u"%1 - %2"_s.arg(m_artist, m_title));
    searchQuery.addQueryItem(u"duration"_s, second);
    searchQuery.addQueryItem(u"hash"_s, first);
    setEncodedQuery(searchUrl, searchQuery);

    auto* searchReply = getJson(searchUrl, kugouHeaders());
    trackReply(reqId, searchReply);

    QObject::connect(searchReply, &QNetworkReply::finished, this,
        [this, searchReply, reqId, startDownload] {
            searchReply->deleteLater();
            if (reqId != m_currentRequestId) {
                return;
            }
            if (searchReply->error() != QNetworkReply::NoError) {
                chainNext(LyricsBackend::Kugou, reqId);
                return;
            }

            const QJsonDocument doc = QJsonDocument::fromJson(searchReply->readAll());
            const QJsonArray candidates = doc.object().value(u"candidates"_s).toArray();
            if (candidates.isEmpty()) {
                chainNext(LyricsBackend::Kugou, reqId);
                return;
            }

            const QJsonObject best = candidates.first().toObject();
            startDownload(best.value(u"id"_s).toString(), best.value(u"accesskey"_s).toString());
        });
}

void Lyrics::fetchQQMusicLyricsById(const QString& id, int reqId) {
    QUrl url(u"https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg"_s);
    QUrlQuery q;
    q.addQueryItem(u"songmid"_s, id);
    q.addQueryItem(u"format"_s, u"json"_s);
    q.addQueryItem(u"nobase64"_s, u"1"_s);
    setEncodedQuery(url, q);

    auto* reply = getJson(url, qqMusicHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId, id] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "qq music lyrics error:" << reply->errorString();
            chainNext(LyricsBackend::QQMusic, reqId);
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        QString text = doc.object().value(u"lyric"_s).toString();
        if (text.isEmpty()) {
            chainNext(LyricsBackend::QQMusic, reqId);
            return;
        }

        if (!text.contains(u'[')) {
            const QByteArray decoded = QByteArray::fromBase64(text.toUtf8());
            if (decoded.contains('[') && decoded.contains(']')) {
                text = QString::fromUtf8(decoded);
            }
        }
        text = decodeHtmlEntities(text);

        const auto lines = parseLrc(text);
        if (lines.isEmpty()) {
            chainNext(LyricsBackend::QQMusic, reqId);
            return;
        }

        writeCachedLrc(LyricsBackend::QQMusic, id, text);
        setLines(lines, LyricsBackend::QQMusic, true);
        const LyricCandidate cand(
            LyricsBackend::QQMusic, id, m_title, m_artist, m_album, m_duration);
        appendCandidates({ cand });
        m_selected = cand;
        emit selectedCandidateChanged();
        if (!m_settingFromPrefs) {
            persistTrackPrefs();
        }
        setLoading(false);
    });
}

void Lyrics::fetchMusixmatchLyricsById(const QString& id, int reqId) {
    QUrl url(id);
    if (!url.isValid() || url.scheme().isEmpty()) {
        chainNext(LyricsBackend::Musixmatch, reqId);
        return;
    }

    auto* reply = getHtml(url, musixmatchHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId, id] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "musixmatch lyrics error:" << reply->errorString();
            chainNext(LyricsBackend::Musixmatch, reqId);
            return;
        }

        const QString text = extractMusixmatchLyrics(QString::fromUtf8(reply->readAll()));
        const auto lines = parsePlainLyrics(text, m_duration);
        if (lines.isEmpty()) {
            chainNext(LyricsBackend::Musixmatch, reqId);
            return;
        }

        setLines(lines, LyricsBackend::Musixmatch, false);
        const LyricCandidate cand(
            LyricsBackend::Musixmatch, id, m_title, m_artist, m_album, m_duration);
        appendCandidates({ cand });
        m_selected = cand;
        emit selectedCandidateChanged();
        if (!m_settingFromPrefs) {
            persistTrackPrefs();
        }
        setLoading(false);
    });
}

void Lyrics::fetchLyricsOvhById(const QString& id, int reqId) {
    QUrl url(id);
    if (!url.isValid() || url.scheme().isEmpty()) {
        chainNext(LyricsBackend::LyricsOvh, reqId);
        return;
    }

    auto* reply = getJson(url);
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId, id] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "lyrics.ovh error:" << reply->errorString();
            chainNext(LyricsBackend::LyricsOvh, reqId);
            return;
        }

        const QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
        const QString text = doc.object().value(u"lyrics"_s).toString();
        const auto lines = parsePlainLyrics(text, m_duration);
        if (lines.isEmpty()) {
            chainNext(LyricsBackend::LyricsOvh, reqId);
            return;
        }

        setLines(lines, LyricsBackend::LyricsOvh, false);
        const LyricCandidate cand(
            LyricsBackend::LyricsOvh, id, m_title, m_artist, m_album, m_duration);
        appendCandidates({ cand });
        m_selected = cand;
        emit selectedCandidateChanged();
        if (!m_settingFromPrefs) {
            persistTrackPrefs();
        }
        setLoading(false);
    });
}

void Lyrics::fetchGeniusLyricsById(const QString& id, int reqId) {
    QString urlText = id;
    if (urlText.startsWith(u'/')) {
        urlText.prepend(u"https://genius.com"_s);
    }
    QUrl url(urlText);
    if (!url.isValid() || url.scheme().isEmpty()) {
        chainNext(LyricsBackend::Genius, reqId);
        return;
    }

    auto* reply = getHtml(url, geniusHeaders());
    trackReply(reqId, reply);

    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply, reqId, id] {
        reply->deleteLater();
        if (reqId != m_currentRequestId) {
            return;
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCDebug(lcLyrics) << "genius lyrics error:" << reply->errorString();
            chainNext(LyricsBackend::Genius, reqId);
            return;
        }

        const QString text = extractGeniusLyrics(QString::fromUtf8(reply->readAll()));
        const auto lines = parsePlainLyrics(text, m_duration);
        if (lines.isEmpty()) {
            chainNext(LyricsBackend::Genius, reqId);
            return;
        }

        setLines(lines, LyricsBackend::Genius, false);
        const LyricCandidate cand(LyricsBackend::Genius, id, m_title, m_artist, m_album, m_duration);
        appendCandidates({ cand });
        m_selected = cand;
        emit selectedCandidateChanged();
        if (!m_settingFromPrefs) {
            persistTrackPrefs();
        }
        setLoading(false);
    });
}

QNetworkReply* Lyrics::get(const QUrl& url, const QHash<QByteArray, QByteArray>& headers) {
    QNetworkRequest req(url);
    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    req.setRawHeader("Cache-Control"_ba, "no-cache, no-store"_ba);
    req.setRawHeader("Pragma"_ba, "no-cache"_ba);
    req.setRawHeader("Connection"_ba, "close"_ba);
    for (auto it = headers.constBegin(); it != headers.constEnd(); ++it) {
        req.setRawHeader(it.key(), it.value());
    }
    return m_nam->get(req);
}

QNetworkReply* Lyrics::getJson(const QUrl& url, const QHash<QByteArray, QByteArray>& headers) {
    QHash<QByteArray, QByteArray> merged = headers;
    merged.insert("Accept"_ba, "application/json"_ba);
    return get(url, merged);
}

QNetworkReply* Lyrics::getHtml(const QUrl& url, const QHash<QByteArray, QByteArray>& headers) {
    QHash<QByteArray, QByteArray> merged = headers;
    merged.insert("Accept"_ba, "text/html,application/xhtml+xml"_ba);
    return get(url, merged);
}

void Lyrics::onPreferredBackendConfigChanged() {
    const LyricsBackend desired = config::ConfigSingleton::instance()->services()->lyricsBackend();
    if (desired == m_preferredBackend) {
        return;
    }
    m_preferredBackend = desired;
    emit preferredBackendChanged();
    scheduleLoad();
}

void Lyrics::onLyricsDirChanged() {
    scheduleLoad();
}

void Lyrics::loadLyricsMap() {
    m_lyricsMap = {};
    m_lyricsMapLoaded = false;

    QFile f(lyricsMapPath());
    if (!f.open(QIODevice::ReadOnly)) {
        m_lyricsMapLoaded = true;
        return;
    }
    const QByteArray bytes = f.readAll();
    f.close();

    QJsonParseError err{};
    const QJsonDocument doc = QJsonDocument::fromJson(bytes, &err);
    if (err.error != QJsonParseError::NoError) {
        qCWarning(lcLyrics) << "lyrics_map.json parse error:" << err.errorString();
        m_lyricsMapLoaded = true;
        return;
    }
    m_lyricsMap = doc.object();
    m_lyricsMapLoaded = true;
}

void Lyrics::persistTrackPrefs() {
    if (!m_lyricsMapLoaded || trackKey().isEmpty()) {
        return;
    }
    const QString key = trackKey();
    QJsonObject entry = m_lyricsMap.value(key).toObject();
    entry.insert(u"offset"_s, m_offset);
    if (m_selected.isValid()) {
        entry.insert(u"backend"_s, backendKey(m_selected.backend()));
        entry.insert(u"id"_s, m_selected.id());
    }
    m_lyricsMap.insert(key, entry);

    QDir().mkpath(stateDir());

    QSaveFile out(lyricsMapPath());
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qCWarning(lcLyrics) << "cannot open" << lyricsMapPath() << "for write:" << out.errorString();
        return;
    }
    const QByteArray bytes = QJsonDocument(m_lyricsMap).toJson(QJsonDocument::Compact);
    if (out.write(bytes) != bytes.size()) {
        qCWarning(lcLyrics) << "short write to" << lyricsMapPath();
        out.cancelWriting();
        return;
    }
    if (!out.commit()) {
        qCWarning(lcLyrics) << "commit failed for" << lyricsMapPath() << ":" << out.errorString();
    }
}

QString Lyrics::lyricsDir() {
    QString dir = config::ConfigSingleton::instance()->paths()->lyricsDir();
    if (dir.isEmpty()) {
        return {};
    }
    if (dir == u"~"_s) {
        dir = QDir::homePath();
    } else if (dir.startsWith(u"~/"_s)) {
        dir.replace(0, 1, QDir::homePath());
    }
    while (dir.endsWith(u'/') && dir.size() > 1) {
        dir.chop(1);
    }
    return dir;
}

QString Lyrics::lyricsMapPath() {
    return stateDir() + u"/lyrics_map.json"_s;
}

QString Lyrics::trackKey() const {
    if (m_artist.isEmpty() && m_title.isEmpty()) {
        return {};
    }
    return u"%1 - %2"_s.arg(joinArtists(m_artist), m_title);
}

QString Lyrics::backendKey(LyricsBackend value) {
    switch (value) {
    case LyricsBackend::Local:
        return u"Local"_s;
    case LyricsBackend::LRCLIB:
        return u"LRCLIB"_s;
    case LyricsBackend::NetEase:
        return u"NetEase"_s;
    case LyricsBackend::Kugou:
        return u"Kugou"_s;
    case LyricsBackend::QQMusic:
        return u"QQMusic"_s;
    case LyricsBackend::Musixmatch:
        return u"Musixmatch"_s;
    case LyricsBackend::LyricsOvh:
        return u"LyricsOvh"_s;
    case LyricsBackend::Genius:
        return u"Genius"_s;
    case LyricsBackend::Auto:
    default:
        return u"Auto"_s;
    }
}

LyricsBackend Lyrics::backendFromKey(const QString& key) {
    if (key.compare(u"Local"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::Local;
    }
    if (key.compare(u"LRCLIB"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::LRCLIB;
    }
    if (key.compare(u"NetEase"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::NetEase;
    }
    if (key.compare(u"Kugou"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::Kugou;
    }
    if (key.compare(u"QQMusic"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::QQMusic;
    }
    if (key.compare(u"Musixmatch"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::Musixmatch;
    }
    if (key.compare(u"LyricsOvh"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::LyricsOvh;
    }
    if (key.compare(u"Genius"_s, Qt::CaseInsensitive) == 0) {
        return LyricsBackend::Genius;
    }
    return LyricsBackend::Auto;
}

const QString& Lyrics::stateDir() {
    static const QString k_dir = [] {
        QString state = qEnvironmentVariable("XDG_STATE_HOME");
        if (state.isEmpty()) {
            state = QDir::homePath() + u"/.local/state"_s;
        }
        return state + u"/caelestia/lyrics"_s;
    }();
    return k_dir;
}

const QString& Lyrics::cacheDir() {
    static const QString k_dir = [] {
        QString cache = qEnvironmentVariable("XDG_CACHE_HOME");
        if (cache.isEmpty()) {
            cache = QDir::homePath() + u"/.cache"_s;
        }
        return cache + u"/caelestia/lyrics"_s;
    }();
    return k_dir;
}

QString Lyrics::cachePathFor(LyricsBackend backend, const QString& id) {
    if (id.isEmpty() || backend == LyricsBackend::Local || !isSyncedBackend(backend)) {
        return {};
    }
    return u"%1/%2/%3.lrc"_s.arg(cacheDir(), backendKey(backend), sanitizeFilenamePart(id));
}

QString Lyrics::readCachedLrc(LyricsBackend backend, const QString& id) {
    const QString path = cachePathFor(backend, id);
    if (path.isEmpty()) {
        return {};
    }
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) {
        return {};
    }
    return QString::fromUtf8(f.readAll());
}

void Lyrics::writeCachedLrc(LyricsBackend backend, const QString& id, const QString& text) {
    if (text.isEmpty()) {
        return;
    }
    const QString path = cachePathFor(backend, id);
    if (path.isEmpty()) {
        return;
    }
    QDir().mkpath(QFileInfo(path).absolutePath());

    QSaveFile out(path);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qCWarning(lcLyrics) << "cannot open" << path << "for write:" << out.errorString();
        return;
    }
    const QByteArray bytes = text.toUtf8();
    if (out.write(bytes) != bytes.size()) {
        qCWarning(lcLyrics) << "short write to" << path;
        out.cancelWriting();
        return;
    }
    if (!out.commit()) {
        qCWarning(lcLyrics) << "commit failed for" << path << ":" << out.errorString();
    }
}

QString Lyrics::tryReadLocalLrc(const QString& dir, const QString& artist, const QString& title) {
    if (artist.isEmpty() && title.isEmpty()) {
        return {};
    }
    const QString flat = u"%1/%2 - %3.lrc"_s.arg(dir, sanitizeFilenamePart(artist), sanitizeFilenamePart(title));
    return QFile::exists(flat) ? flat : QString();
}

QString Lyrics::findLocalLrcRecursive(const QString& dir, const QString& artist, const QString& title) {
    if (dir.isEmpty()) {
        return {};
    }
    if (artist.isEmpty() && title.isEmpty()) {
        return {};
    }

    QDirIterator it(dir, QStringList{ u"*.lrc"_s }, QDir::Files | QDir::NoDotAndDotDot,
        QDirIterator::Subdirectories | QDirIterator::FollowSymlinks);

    while (it.hasNext()) {
        const QString path = it.next();
        const QString name = it.fileName();
        if ((artist.isEmpty() || containsCi(name, artist)) && (title.isEmpty() || containsCi(name, title))) {
            return path;
        }
    }
    return {};
}

QVector<LyricLine> Lyrics::parseLrc(const QString& text) {
    QVector<LyricLine> result;
    if (text.isEmpty()) {
        return result;
    }

    static const QRegularExpression k_timeRegex(u"\\[(\\d+):(\\d+(?:\\.\\d+)?)\\]"_s);
    static const QStringList k_creditKeywords = {
        u"作词"_s,
        u"作曲"_s,
        u"编曲"_s,
        u"制作"_s,
        u"收录"_s,
        u"演奏"_s,
        u"词："_s,
        u"曲："_s,
        u"Lyricist"_s,
        u"Composer"_s,
        u"Arranger"_s,
        u"Producer"_s,
        u"Mixing"_s,
        u"Mastering"_s,
    };

    const QStringList lines = text.split(u'\n');
    for (const QString& line : lines) {
        QList<QRegularExpressionMatch> matches;
        auto it = k_timeRegex.globalMatch(line);
        while (it.hasNext()) {
            matches.append(it.next());
        }
        if (matches.isEmpty()) {
            continue;
        }

        QString lyric = line;
        lyric.replace(k_timeRegex, QString());
        lyric = lyric.trimmed();

        const qreal firstTime = matches.first().captured(1).toInt() * 60.0 + matches.first().captured(2).toDouble();

        if (firstTime < 20.0) {
            bool isCredit = false;
            for (const QString& k : k_creditKeywords) {
                if (lyric.contains(k, Qt::CaseInsensitive)) {
                    isCredit = true;
                    break;
                }
            }
            if (isCredit && (lyric.contains(u':') || lyric.contains(QChar(0xFF1A)) || lyric.size() < 25)) {
                continue;
            }
        }

        for (const auto& m : matches) {
            const qreal t = m.captured(1).toInt() * 60.0 + m.captured(2).toDouble();
            result.append(LyricLine{ .time = t, .text = lyric });
        }
    }

    std::ranges::sort(result, [](const LyricLine& a, const LyricLine& b) {
        return a.time < b.time;
    });

    return result;
}

QVector<LyricLine> Lyrics::parsePlainLyrics(const QString& text, qreal duration) {
    QStringList lines;
    for (QString line : text.split(u'\n')) {
        line.remove(u'\r');
        line = line.trimmed();
        if (line.isEmpty()) {
            continue;
        }
        if (line.startsWith(u'[') && line.endsWith(u']')) {
            continue;
        }
        if (line.startsWith(u"Writer(s):"_s, Qt::CaseInsensitive)
            || line.startsWith(u"Lyrics powered by"_s, Qt::CaseInsensitive)
            || line.startsWith(u"Embed"_s, Qt::CaseInsensitive)) {
            continue;
        }
        lines.append(line);
    }

    const qsizetype count = lines.size();
    if (count == 0) {
        return {};
    }

    QVector<LyricLine> result;
    result.reserve(count);
    if (duration > 1.0) {
        const qreal start = 0.5;
        const qreal end = qMax(start + 1.0, duration - 0.5);
        const qreal step = (end - start) / static_cast<qreal>(count);
        for (qsizetype i = 0; i < count; ++i) {
            result.append(LyricLine{ .time = start + step * static_cast<qreal>(i), .text = lines.at(i) });
        }
    } else {
        for (qsizetype i = 0; i < count; ++i) {
            result.append(LyricLine{ .time = 4.0 * static_cast<qreal>(i), .text = lines.at(i) });
        }
    }

    return result;
}

} // namespace caelestia::services
