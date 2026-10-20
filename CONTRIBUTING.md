# Contribuir a Caelestia ES

Caelestia ES es una versión comunitaria derivada de Caelestia y MiDnight.
Los orígenes del código se documentan en [docs/UPSTREAM.md](docs/UPSTREAM.md)
y las personalizaciones en [docs/CUSTOMIZATIONS.md](docs/CUSTOMIZATIONS.md).

## Proponer cambios aquí

Describe el problema, los archivos afectados y cómo comprobaste el cambio.
Para cambios visuales, incluye capturas y los pasos para reproducir el resultado.
Indica las versiones de Quickshell, Qt y Caelestia CLI cuando sean relevantes.
Evita incluir preferencias de hardware o rutas personales como valores generales.
Conserva los créditos, los avisos de autoría y las licencias correspondientes.

## Aportar a los proyectos originales

Esta instantánea combina componentes de varios proyectos y tiene un historial
propio. Para enviar una mejora al original:

1. Identifica dónde se mantiene actualmente el componente y lee sus instrucciones
   de contribución. Empieza por los enlaces de [upstream](docs/UPSTREAM.md).
2. Crea un fork de ese repositorio y una rama basada en su versión actual.
3. Porta una mejora concreta, con sus dependencias necesarias. Por ejemplo:
   traducciones, letras, fuentes o QuickShare, cada una por separado.
4. Comprueba el cambio sobre esa base y documenta cómo reproducirlo.
5. Abre el pull request explicando el problema y el comportamiento resultante,
   con un enlace a Caelestia ES como contexto cuando corresponda.

Las configuraciones de aplicaciones corresponden al proyecto de dotfiles;
el QML y el plugin C++ corresponden al shell del que proceden; los cambios
Python deben contrastarse con el CLI. Comprueba el destino antes de abrir
cada propuesta: no todos estos componentes se mantienen en el repositorio
principal de dotfiles.

El parche Python local puede servir como referencia para una mejora del CLI,
pero conviene implementar allí el cambio directamente en su código, siguiendo
la arquitectura de ese proyecto.

Publicar Caelestia ES y enviar mejoras al upstream son acciones complementarias.
Mantén la atribución de los proyectos originales y distingue los cambios propios
de los heredados; no es necesario borrar el historial de esta versión.
