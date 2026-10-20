from pathlib import Path
from types import SimpleNamespace

from materialyoucolor.hct import Hct
from caelestia.utils.material.generator import gen_scheme

OUT = Path.home() / ".local/share/caelestia/schemes"

THEMES = {
    "kanagawa": {
        "seed": "7E9CD8",
        "dark": ("1F1F28", "DCD7BA", "727169", "16161D", "C8C093"),
        "light": ("F2ECBC", "545464", "8A8980", "1F1F28", "F2ECBC"),
        "red": "E46876",
        "orange": "FFA066",
        "yellow": "E6C384",
        "green": "98BB6C",
        "cyan": "7AA89F",
        "blue": "7E9CD8",
        "purple": "957FB8",
        "magenta": "D27E99",
    },
    "monokai": {
        "seed": "F92672",
        "dark": ("272822", "F8F8F2", "75715E", "1E1F1C", "F8F8F2"),
        "light": ("F8F8F2", "272822", "75715E", "272822", "F8F8F2"),
        "red": "F92672",
        "orange": "FD971F",
        "yellow": "E6DB74",
        "green": "A6E22E",
        "cyan": "66D9EF",
        "blue": "66D9EF",
        "purple": "AE81FF",
        "magenta": "F92672",
    },
    "github": {
        "seed": "58A6FF",
        "dark": ("0D1117", "C9D1D9", "8B949E", "010409", "F0F6FC"),
        "light": ("FFFFFF", "24292F", "57606A", "24292F", "FFFFFF"),
        "red": "FF7B72",
        "orange": "FFA657",
        "yellow": "E3B341",
        "green": "7EE787",
        "cyan": "79C0FF",
        "blue": "58A6FF",
        "purple": "D2A8FF",
        "magenta": "FF7B72",
    },
    "ayu": {
        "seed": "FFB454",
        "dark": ("0B0E14", "BFBDB6", "565B66", "01040A", "E6E1CF"),
        "light": ("FAFAFA", "5C6773", "8A9199", "5C6773", "FFFFFF"),
        "red": "F07178",
        "orange": "FFB454",
        "yellow": "E6B673",
        "green": "AAD94C",
        "cyan": "95E6CB",
        "blue": "59C2FF",
        "purple": "D2A6FF",
        "magenta": "F07178",
    },
    "nightfox": {
        "seed": "719CD6",
        "dark": ("192330", "CDCECF", "738091", "131A24", "DFDFE0"),
        "light": ("F2F4F8", "29394F", "738091", "29394F", "FFFFFF"),
        "red": "C94F6D",
        "orange": "F4A261",
        "yellow": "DBC074",
        "green": "81B29A",
        "cyan": "63CDCF",
        "blue": "719CD6",
        "purple": "9D79D6",
        "magenta": "C94F6D",
    },
    "melange": {
        "seed": "7F91B2",
        "dark": ("292522", "ECE1D7", "867462", "1F1B18", "F5EDE4"),
        "light": ("F1ECE5", "54433A", "867462", "54433A", "FFFFFF"),
        "red": "D47766",
        "orange": "EBC06D",
        "yellow": "EBC06D",
        "green": "A3BE8C",
        "cyan": "7FB4CA",
        "blue": "7F91B2",
        "purple": "B380B0",
        "magenta": "D47766",
    },
    "oxocarbon": {
        "seed": "33B1FF",
        "dark": ("161616", "F2F4F8", "525252", "0A0A0A", "FFFFFF"),
        "light": ("F2F4F8", "161616", "525252", "161616", "FFFFFF"),
        "red": "FF7EB6",
        "orange": "FF832B",
        "yellow": "F1C21B",
        "green": "42BE65",
        "cyan": "3DDBD9",
        "blue": "33B1FF",
        "purple": "BE95FF",
        "magenta": "FF7EB6",
    },
    "flexoki": {
        "seed": "4385BE",
        "dark": ("100F0F", "CECDC3", "6F6E69", "0A0A0A", "FFFCF0"),
        "light": ("FFFCF0", "100F0F", "6F6E69", "100F0F", "FFFCF0"),
        "red": "D14D41",
        "orange": "DA702C",
        "yellow": "D0A215",
        "green": "879A39",
        "cyan": "3AA99F",
        "blue": "4385BE",
        "purple": "8B7EC8",
        "magenta": "CE5D97",
    },
}


def hct(value: str) -> Hct:
    return Hct.from_int(int(value.replace("#", ""), 16))


def hex_value(colour: Hct) -> str:
    return hex(colour.to_int())[4:].upper()


def shift(value: str, delta: float) -> str:
    colour = hct(value)
    colour.tone = max(0.0, min(100.0, colour.tone + delta))
    return hex_value(colour)


def make_mapping(theme: dict, variant: str, mode: str, bg: str, fg: str, muted: str, black: str, white: str, accents: dict) -> dict[str, str]:
    fake = SimpleNamespace(name="local", flavour="default", mode=mode, variant=variant)
    colours = gen_scheme(fake, hct(theme["seed"]))
    colours = {k: v.upper() for k, v in colours.items()}

    # Move the generated surface ramp to the theme's background tone while
    # keeping the relative Material elevation ordering.
    delta = hct(bg).tone - hct(colours["surface"]).tone
    for name in list(colours):
        if name.startswith("surface") or name == "background":
            colours[name] = shift(colours[name], delta)

    colours["background"] = bg
    colours["surface"] = bg
    colours["surfaceDim"] = shift(bg, -3 if mode == "dark" else -5)
    colours["onBackground"] = fg
    colours["onSurface"] = fg
    colours["onSurfaceVariant"] = muted
    colours["outline"] = muted
    colours["outlineVariant"] = shift(muted, 18 if mode == "dark" else -18)
    colours["inverseSurface"] = fg
    colours["inverseOnSurface"] = bg
    colours["surfaceTint"] = colours.get("primary", accents["blue"])

    terms = {
        "term0": black,
        "term1": accents["red"],
        "term2": accents["green"],
        "term3": accents["yellow"],
        "term4": accents["blue"],
        "term5": accents["purple"],
        "term6": accents["cyan"],
        "term7": white if mode == "dark" else fg,
        "term8": muted,
        "term9": accents["orange"],
        "term10": accents["green"],
        "term11": accents["yellow"],
        "term12": accents["blue"],
        "term13": accents["purple"],
        "term14": accents["cyan"],
        "term15": white if mode == "dark" else fg,
    }
    colours.update(terms)

    named = {
        "rosewater": white if mode == "dark" else fg,
        "flamingo": accents["magenta"],
        "pink": accents["magenta"],
        "mauve": accents["purple"],
        "red": accents["red"],
        "maroon": accents["red"],
        "peach": accents["orange"],
        "yellow": accents["yellow"],
        "green": accents["green"],
        "teal": accents["cyan"],
        "sky": accents["cyan"],
        "sapphire": accents["blue"],
        "blue": accents["blue"],
        "lavender": accents["purple"],
    }
    colours.update(named)

    colours["klink"] = accents["blue"]
    colours["klinkSelection"] = accents["blue"]
    colours["kvisited"] = accents["purple"]
    colours["kvisitedSelection"] = accents["purple"]
    colours["knegative"] = accents["red"]
    colours["knegativeSelection"] = accents["red"]
    colours["kneutral"] = accents["yellow"]
    colours["kneutralSelection"] = accents["yellow"]
    colours["kpositive"] = accents["green"]
    colours["kpositiveSelection"] = accents["green"]

    colours["text"] = fg
    colours["subtext1"] = shift(fg, -10 if mode == "dark" else 10)
    colours["subtext0"] = muted
    colours["overlay2"] = shift(fg, -20 if mode == "dark" else 20)
    colours["overlay1"] = shift(fg, -30 if mode == "dark" else 30)
    colours["overlay0"] = muted
    colours["surface2"] = shift(bg, 12 if mode == "dark" else -12)
    colours["surface1"] = shift(bg, 7 if mode == "dark" else -7)
    colours["surface0"] = shift(bg, 3 if mode == "dark" else -3)
    colours["base"] = bg
    colours["mantle"] = shift(bg, -2)
    colours["crust"] = shift(bg, -4)

    return colours


def write_colours(path: Path, colours: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(f"{name} {value}" for name, value in colours.items()) + "\n")


def main() -> None:
    for name, theme in THEMES.items():
        for mode in ("dark", "light"):
            bg, fg, muted, black, white = theme[mode]
            accents = {key: theme[key] for key in ("red", "orange", "yellow", "green", "cyan", "blue", "purple", "magenta")}
            colours = make_mapping(theme, "tonalspot", mode, bg, fg, muted, black, white, accents)
            write_colours(OUT / name / "default" / f"{mode}.txt", colours)
            print(f"{name}/{mode}: {len(colours)} colours")


if __name__ == "__main__":
    main()
