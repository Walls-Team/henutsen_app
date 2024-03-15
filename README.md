# henutsen_cli
[![Copyright © AudiSoft Consulting][audisoft_badge]][audisoft_url] [![Copyright © Ideas Control][ideas_badge]][ideas_url]

[audisoft_badge]: https://img.shields.io/badge/Copyright%20%C2%A9%202020%20-AudiSoft-orange (Copyright © AudiSoft Consulting)
[audisoft_url]: https://www.audisoft.com/

[ideas_badge]: https://img.shields.io/badge/Copyright%20%C2%A9%202020%20-Ideas%20Control-orange (Copyright © Ideas Control)
[ideas_url]: https://www.ideascontrol.com/

Aplicación cliente de Henutsen.

## Features and bugs
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Henutsen/chainway_r6_plugin/issues


# Creación de página web henutsen.co

Ingresar a la carpeta scripts del proyecto henutsen_cli

Ejecutar script script-create.sh con el siguiente comando 
"sh script-create.sh /ruta_archivos_página_web"

# Eliminado completo de la página web henutsen.co

Ingresar a la carpeta scripts del proyecto henutsen_cli

Ejecutar script script-delete.sh con el siguiente comando 
"sh script-create.sh"

# Publicación de nueva versión de app henutsen 

Se ingresa a la ruta del repositorio 
"~/ruta_donde_esta_el_repositorio/audisoft_cloud/old/henutsen_cli" 

Se cambia el número de versión

Se compila el proyecto para generar los binarios ejecutando el siguiente comando

*Binarios para página web configurado a QA
"flutter build web --dart-define=DEFINE_CONFIG_FILE=config/qa_config.json" 

*Binarios para página web configurado a producción
"flutter build web --dart-define=DEFINE_CONFIG_FILE=config/prod_config.json" 


Se ingresa a la ruta del repositorio donde se generan los binarios
"~/ruta_donde_esta_el_repositorio/audisoft_cloud/old/henutsen_cli/build/web" 

Se copian todos archivos de esa carpeta y se deben colocar en la siguiente ruta 
"~/ruta_donde_esta_el_repositorio/audisoft_cloud/old/henutsen_cli/web/co/app"

Se ejecuta script storageaccount.sh
"sh storageaccount.sh ~/ruta_donde_esta_el_repositorio/audisoft_cloud/old/henutsen_cli/web/co"

# Generación binarios appbundle (Publicación play store) 
*apuntando a QA
"flutter build appbundle --dart-define=DEFINE_CONFIG_FILE=config/qa_config.json"

*Apuntando a producción
"flutter build appbundle --dart-define=DEFINE_CONFIG_FILE=config/prod_config.json"

# Generación binarios para apk (Instalación directa al celular) 

*apuntando a QA
"flutter build apk --dart-define=DEFINE_CONFIG_FILE=config/qa_config.json"

*Apuntando a producción
"flutter build apk --dart-define=DEFINE_CONFIG_FILE=config/prod_config.json"






