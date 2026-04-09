-- @ScriptType: Script
--[[

VERSION: 0.4.1

************************************************
************GENERAR PARTICULAS DE FUEGO
************************************************
******DEFINICION************
GenerarFuego(Model, Direccion,[OPCIONAL]Borrado)
******DESCRIPCION************
Genera particulas de fuego
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Direccion - (String) - determina en qué dirección van las partículas. Usa los valores del Enumerado de direcciones del particle emitter. Se pasa por parametros
uno de los siguientes: ("Top","Back","Bottom","Front","Left","Right")
Borrado - booleano - si se pone true, borra el efecto EfectoFuego que haya en el modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************GENERAR EFECTO NOTAS MUSICALES FUERA
************************************************
******DEFINICION************
GenerarEfectoNotasFuera(modelo,direccionEmision,[OPCIONAL]Borrado) 
******DESCRIPCION************
Genera particulas en forma de nota musical
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Direccion - (String) - determina en qué dirección van las partículas. Usa los valores del Enumerado de direcciones del particle emitter. Se pasa por parametros
uno de los siguientes: ("Top","Back","Bottom","Front","Left","Right")
borrado - boolean - determina si se borra el efecto (true) o si se crea(false/nil)
************************************************

************************************************
************GENERAR EFECTO NOTAS MUSICALES DENTRO
************************************************
******DEFINICION************
GenerarEfectoNotasDentro(modelo)
******DESCRIPCION************
Genera particulas en forma de nota musical que se desplazan desde el exterior hacia el modelo de manera aleatoria. El emisor se borra a si mismo pasados 4 segundos
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
************************************************

************************************************
************GENERAR EFECTO BENGALA
************************************************
******DEFINICION************
GenerarEfectoBengala(modelo,[OPCIONAL]Borrado) 
******DESCRIPCION************
Genera particulas en forma de chispa roja simulando una bengala como las usadas en un concierto
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
borrado - boolean - determina si se borra el efecto (true) o si se crea(false/nil)
************************************************

************************************************
************GENERAR EFECTO ESTRELLA TWEEN
************************************************
******DEFINICION************
GenerarEstrellaTween(position,color) 
******DESCRIPCION************
Genera una estrella 3D que asciende mientras rotay se encoge
******VARIABLES************
position - vector3 - posición de la estrella
Color - color - un Color3 con el color del que se desee que sea la estrella
************************************************

************************************************
************GENERAR EFECTO ESTRELLAS
************************************************
******DEFINICION************
GenerarEfectoEstrellas(position,color)
******DESCRIPCION************
Genera un burst de particulas en forma de estrella. El emisor se borra a si mismo pasados un segundo
******VARIABLES************
position - vector3 - posición del burst de partículas
Color - color - un Color3 con el color del que se desee que sea el brillo
************************************************

************************************************
************GENERAR EFECTO ESTRELLAS PLAYER
************************************************
******DEFINICION************
GenerarEfectoEstrellasPlayer(modeloJugador,color)
******DESCRIPCION************
Genera particulas brillantes grandes en forma de estrella que se desplazan desde el exterior hacia el modelo del jugador de manera aleatoria. El emisor se borra a si mismo pasados 5 segundos
******VARIABLES************
modeloJugador - model - el modelo de un player
Color - color - un Color3 con el color del que se desee que sea el brillo
************************************************

************************************************
************GENERAR EFECTO BRILLO
************************************************
******DEFINICION************
GenerarEfectoBrillo(modelo,color,borrado)
******DESCRIPCION************
Genera particulas brillantes, como las usadas para indicar un drop
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Color - color - un Color3 con el color del que se desee que sea el brillo
Borrado - Booleano - si se pone true, borra el efecto EfectoBrillo que haya en el modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************GENERAR EFECTO HUMO
************************************************
******DEFINICION************
GenerarEfectoHumo(modelo,color, borrado)
******DESCRIPCION************
Genera particulas crises oscuras simulando humo. Tambien se puede modificar para que simule vapor
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Color - color - un Color3 con el color del que se desee que sea el humo
Borrado - Boolean - si se pone true, borra el efecto EfectoHumo que haya en el modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************GENERAR EFECTO SANGRE
************************************************
******DEFINICION************
GenerarEfectoSangre(modelo,direccion)
******DESCRIPCION************
Genera un burst de pequeñas particulas rojo oscuro para simular una salpicadura de sangre
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Direccion - (String) - determina en qué dirección van las partículas. Usa los valores del Enumerado de direcciones del particle emitter. Se pasa por parametros
uno de los siguientes: ("Top","Back","Bottom","Front","Left","Right")
************************************************

************************************************
************GENERAR EFECTO NOTA PERFECTA
************************************************
******DEFINICION************
GenerarEfectoNotaPerfecta(modelo)
******DESCRIPCION************
Genera un burst de particulas doradas. Se puede usar para indicar que una nota se ha tocado en el momento justo en un juego de ritmo por ejemplo
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
************************************************

************************************************
************GENERAR FUENTE DE AGUA
************************************************
******DEFINICION************
GenerarFuenteAgua(modelo, borrado)
******DESCRIPCION************
Genera un chorro de particulas azules. Se puede usar para simular un chorro de agua de una fuente, un aspersor, etc
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Borrado - Boolean - si se pone true, borra el efecto EfectoFuenteAgua que haya en el modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************GENERAR EFECTO BURBUJAS
************************************************
******DEFINICION************
GenerarBurbujas(modelo, color, borrado)
******DESCRIPCION************
Genera particulas redondas que simulan burbujas. Se puede usar para hacer un efecto como el de envenenamiento en monster hunter, o de estar lleno de jabón
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
Color - color - un Color3 con el color del que se desee que sean las burbujas
Borrado - Boolean - si se pone true, borra el efecto EfectoBurbujas que haya en el modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************GENERAR BOLA DE FUEGO
************************************************
******DEFINICION************
EfectoBolaGiratoria(posicion, color, borrado, player)
******DESCRIPCION************
Genera un modelo de una bola de fuego con partes que rotan para simular una explosión, etc. Se destruye solo al cabo de 30 segundos
******VARIABLES************
Posicion - Vector3 - Posicion en la que spawnear la bola 
Color - color - un Color3 con el color del que se desee que sea la bola del interior
PlayBorrado - Boolean - si se pone true, borra el efecto EfectoBolaGiratoria que haya en el workspace, si se pone a false o nil, crea el efecto
er - Player - De el obtenemos su nombre para identificar de quien es el efecto spawneado
************************************************

************************************************
************GENERAR EFECTO BOOST
************************************************
******DEFINICION************
EfectoBoost(player,lvl,borrado)
******DESCRIPCION************
Genera un modelo de un efecto de boost con partes que rotan. A mayor nivel, mas partes. Se destruye solo al cabo de unos segundos
******VARIABLES************
Player - Player - Jugador al que le enganchamos el efecto de boost
lvl - integer - Nivel del boost. (De momento solo hay rango 0 y rango 1)
Borrado - Boolean - si se pone true, borra el efecto EfectoBoost que haya en el player, si se pone a false o nil, crea el efecto
************************************************

************************************************
************CHECK ANIME POSICION
************************************************
******DEFINICION************
EfectoCheckAnimePosicion(posicion, borrado)
******DESCRIPCION************
Genera un modelo de una nube con rayos, con partes que rotan para simular una explosión de poder, etc. Se destruye solo al cabo de unos segundos
******VARIABLES************
Posicion - Vector3 - Posicion en la que spawnear el efecto 
Borrado - Boolean - si se pone true, borra el efecto EfectoBolaGiratoria que haya en el workspace, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************CHECK ANIME MODEL
************************************************
******DEFINICION************
EfectoCheckAnimeModel(model, borrado)
******DESCRIPCION************
Genera un modelo de una nube con rayos, con partes que rotan para simular una explosión de poder, etc. Se destruye solo al cabo de unos segundos
******VARIABLES************
Model- model - modelo en el que spawnear el efecto
Borrado - Boolean - si se pone true, borra el efecto EfectoBolaGiratoria que haya en el workspace, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************Generar Efecto Trail 
************************************************
******DEFINICION************
EfectoTrail(player, colorSequence, borrado)
******DESCRIPCION************
Genera un rastro detrás del jugador que se pasa por parámetros, con la secuencia de color pasada por parámetros.
******VARIABLES************
Player – Player – Jugador al que se le pone el trail
colorSequence – ColorSequence – un ColorSequence con los colores que queremos que adopte el trail
Borrado – Boolean – si se pone true, borra el Trail que haya en el player, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************Generar Efecto Radioactivo 
************************************************
******DEFINICION************
EfectoRadioactivo(model,borrado)
******DESCRIPCION************
Genera una serie de partículas que simulan ondas de radiación de color verde chillón
******VARIABLES************
Model – Model – Modelo en el que spawnear el efecto
Borrado – Boolean – Si se pone true, borra el EfectoRadioactivo que haya en el primary part del modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************Generar Efecto Super  
************************************************
******DEFINICION************
EfectoSuper(model, colorSequence, borrado)
******DESCRIPCION************
Genera un efecto de aura de poder con pequeñas partículas de rayos alrededor del PrimaryPart de un Modelo
******VARIABLES************
Model – Model – Modelo en el que spawnear el efecto. Puede ser un modelo cualquiera o el player.character de un player también, porque del modelo usamos su PrimaryPart
colorSequence – ColorSequence – un ColorSequence con los colores que queremos que adopte el aura
Borrado – Boolean – Si se pone true, borra el EfectoSuper que haya en el PrimaryPart del modelo, si se pone a false, o se deja vacío, crea el efecto
************************************************

************************************************
************Generar Efecto Blast   
************************************************
******DEFINICION************
EfectoBlast(model,colorSequenceCarga,colorExplosionPrincipio,colorExplosionFin)
******DESCRIPCION************
Genera un efecto de rayos de carga tras el cual, destruye el efecto de rayos y se genera una explosión en la última posición del model. Al acabar la explosión, esta es destruida también.
Contiene un wait()
******VARIABLES************
Model – Model – Modelo en el que spawnear el efecto. Puede ser un modelo cualquiera o el player.character de un player también, porque del modelo usamos su PrimaryPart
colorSequenceCarga – ColorSequence – un ColorSequence con los colores que queremos que adopten los rayos/brillos del efecto de carga
colorExplosionPrincipio – Color3 – Color que queremos para la esfera de la explosión al principio
colorExplosionFin – Color3 – Color que queremos para la esfera de la explosión al final
************************************************

************************************************
************Generar Efecto Bloque 
************************************************
******DEFINICION************
EfectoBloque(model)
******DESCRIPCION************
Genera un efecto de explosión de partículas irisiadas y triangulitos de color azul, como al romper un bloque en mario kart, al acabar se destruye solo
******VARIABLES************
Model – Model – Modelo en el que spawnear el efecto
************************************************

************************************************
************Generar Efecto Speed
************************************************
******DEFINICION************
EffectsManager.Speed(player, borrado)
******DESCRIPCION************
Genera un efecto de velocidad, con rayos azules como trails y un emisor de rayos para mayor sensación de velocidad
******VARIABLES************
Player - Player - Player al que se le pone el efecto de velocidad
Borrado - bool - True si queremos que se borre, false o null si queremos crearlo
************************************************

************************************************
************Generar Efecto Bala Básica
************************************************
******DEFINICION************
BasicBullet(modelo,modeloTarget,retardo, borrado)
******DESCRIPCION************
Genera una bala esférica, amarilla y brillante, que se mueve desde modelo a modelo Target, con el retardo indicado
******VARIABLES************
modelo - model - modelo del que sale la bala, del cual usamos su primary part
modeloTarget - Model - modelo al que va la bala, del cual usamos su primary part
retardo - int - cuanto queremos que tarde la bala en llegar, a mayor número, mas lento irá
Borrado - bool - True si queremos que se borre, false o null si queremos crearlo
************************************************

************************************************
************Generar Efecto Bala Fuego
************************************************
******DEFINICION************
FireBullet(modelo,modeloTarget,retardo, borrado)
******DESCRIPCION************
Genera una bala esférica, naranja y ardiente, que se mueve desde modelo a modelo Target, con el retardo indicado
******VARIABLES************
modelo - model - modelo del que sale la bala, del cual usamos su primary part
modeloTarget - Model - modelo al que va la bala, del cual usamos su primary part
retardo - int - cuanto queremos que tarde la bala en llegar, a mayor número, mas lento irá
Borrado - bool - True si queremos que se borre, false o null si queremos crearlo
************************************************

************************************************
************Generar Efecto Beam Rayo
************************************************
******DEFINICION************
RayoBeam(modelo,modeloTarget,borrado)
******DESCRIPCION************
Genera un beam eléctrico, que va desde modelo a modeloTarget
******VARIABLES************
modelo - model - modelo del que sale la bala, del cual usamos su primary part
modeloTarget - Model - modelo al que va la bala, del cual usamos su primary part
Borrado - bool - True si queremos que se borre, false o null si queremos crearlo
************************************************

************************************************
************Generar Efecto Rayo Bala
************************************************
******DEFINICION************
RayoBala(modelo,modeloTarget)
******DESCRIPCION************
Genera un part que simula el efecto de una bala trazadora en el aire, que va desde modelo a modelo target, y que se desvanece pasado unos segundos, y al acabar, se destruye
******VARIABLES************
modelo - model - modelo del que sale la bala, del cual usamos su primary part
modeloTarget - Model - modelo al que va la bala, del cual usamos su primary part
************************************************

************************************************
************Generar Efecto ShockWave
************************************************
******DEFINICION************
GenerarEfectoShockWave(modelo, colorInicio, colorFinal, finalSize, duracion)
******DESCRIPCION************
Genera un efecto de onda expansiva/ onda de choque
******VARIABLES************
modelo - model - modelo del que sale la onda, del cual usamos su primary part
colorInicio - Color3 - color inicial que queremos para los anillos
colorFinal - Color3 - color final que queremos para los anillos
finalSize - Vector3 - tamaño que queremos que alcancen los anillos (el segundo anillo será de la mitad del tamaño del primero)
duración - numero - tiempo que queremos que tarde el tween en ejecutarse. cuanto mas pequeño sea, más rapido se ejecuta
************************************************


************************************************
************Generar Efecto Kirbo
************************************************
******DEFINICION************
EfectoKirbo(modelo)
******DESCRIPCION************
Efecto que simula una explosión del kirby
******VARIABLES************
modelo - model - modelo del que sale el efecto, del cual usamos su primary part
************************************************

************************************************
************Generar Efecto Humo Carreras
************************************************
******DEFINICION************
GenerarEfectoHumoCarreras(modelo,color,borrado)
******DESCRIPCION************
Efecto que simula el humo de un tubo de escape, el polvo que suelta un vehículo, etc... al moverse
******VARIABLES************
model - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
color - color3 - color del humo
borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
************************************************

************************************************
************Generar Chispas Experiencia
************************************************
******DEFINICION************
GenerarChispasExperiencia(modelo)
******DESCRIPCION************
Efectito que pone unas particulas de color similar al fuego, y se autodestruyen pasados unos 2 segundos. El emitter se mete en el primary part del modelo pasado por parámetros
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
************************************************

************************************************
************Generar Efecto Velocidad SpeedPad
************************************************
******DEFINICION************
SpeedPad(model, duracion)
******DESCRIPCION************
Efectito que pone unas particulas que simulan líneas de velocidad al ir muy rápido por pisar un speedpad, se destruyen solas pasados unos segundos
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
duración - number - el tiempo que dura el efecto antes de desaparecer
************************************************

************************************************
************Generar Efecto Fuego Carreras
************************************************
******DEFINICION************
GenerarFuegoCarreras(modelo,borrado)
******DESCRIPCION************
Efecto que simula el fuego de un tubo de escape al hacer turbo
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
************************************************

************************************************
************Generar Efecto Brillos Trucos
************************************************
******DEFINICION************
EfectoBrillosTrucos(modelo)
******DESCRIPCION************
Efectito que pone unas particulas circulares irisiadas como las que salen al hacer trucos en MK y desaparecen a los pocos segundos. El emitter se mete en el primary part del modelo pasado por parámetros
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
************************************************

************************************************
************Generar Efecto Fuego Nivel
************************************************
******DEFINICION************
GenerarFuegoNivel(modelo)
******DESCRIPCION************
Efectito que pone pequeñas llamitas y brillos con el color del fuego en el jugador para que vea que ha subido de nivel, se destruye solo pasados unos pocos segundos. El emitter se mete en el primary part del modelo pasado por parámetros
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
************************************************

************************************************
************Generar Efecto Ascension
************************************************
******DEFINICION************
EfectoAscension(model, colorSequence)
******DESCRIPCION************
Efectito que pone un efecto parecido al de super en el jugador para indicar que ha ascendido, se destruye solo pasados unos pocos segundos. El emitter se mete en el primary part del modelo pasado por parámetros y se puede ajustar el color del aura
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
colorSequence - colorSequence - colorSequence con los colores que queremos para el aura
************************************************

************************************************
************Generar Efecto Chispas Drift
************************************************
******DEFINICION************
EfectoChispasDrift(modelo, direccion, color, borrado)
******DESCRIPCION************
Efectito que pone chispas en los laterales del modelo para indicar que está haciendo drifting. Está hecho de manera que si existiese este efecto ya antes en un modelo, se modifiquen los parámetros del existente, para permitir cambiar el color y la dirección de las chispas en tiempo real sin que se corten.
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
dirección - String - "Left" para que salgan hacia la izquierda, "Right" para que salgan hacia la derecha
color - color3 - color de las chispas
borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
************************************************

************************************************
************Generar Efecto Salpicadura
************************************************
******DEFINICION************
EfectoSalpicadura(modelo,borrado)
******DESCRIPCION************
Efecto que simula salpicaduras en el agua. está diseñado para que el efecto se quede puesto hasta que se indique lo contrario
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
************************************************

************************************************
************Generar Efecto Hover
************************************************
******DEFINICION************
Hover(model, borrado)
******DESCRIPCION************
Efecto que lineas de aire al hacer hover, como en genshin. está diseñado para que el efecto se quede puesto hasta que se indique lo contrario
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
borrado - boolean - true si queremos borrar el efecto, false o nil para crearlo
************************************************

************************************************
************Generar Efecto Roca
************************************************
******DEFINICION************
GenerarEfectoRoca(modelo)
******DESCRIPCION************
Efecto que simula las partículas al romper una roca, como polvo y gravilla. Se destruye solo pasados unos pocos segundos.
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
************************************************

************************************************
************Generar Efecto Hueso
************************************************
******DEFINICION************
GenerarEfectoHueso(modelo)
******DESCRIPCION************
Efecto similar al de las partículas de roca, pero que simula trocitos de hueso blancos. Se destruye solo pasados unos pocos segundos.
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
************************************************

************************************************
************Generar Bala de Agua
************************************************
******DEFINICION************
WaterBullet(modelo,modeloTarget,retardo)
******DESCRIPCION************
Efecto que simula una bala de agua que va de A a B, se destruye al llegar al objetivo
******VARIABLES************
modelo - Modelo - modelo donde se spawnea la bala, que debe tener un primary part
modeloTarget - Modelo - modelo hacia donde se apunta la bala, debe tener un primary part
retardo - numero- tiempo que tarda la bala en ir del punto A al B
************************************************

************************************************
************Generar Bala de Tornillos
************************************************
******DEFINICION************
ScrewBullet(modelo,modeloTarget,retardo)
******DESCRIPCION************
Efecto que simula una bala de tornillos que va de A a B, se destruye al llegar al objetivo
******VARIABLES************
modelo - Modelo - modelo donde se spawnea la bala, que debe tener un primary part
modeloTarget - Modelo - modelo hacia donde se apunta la bala, debe tener un primary part
retardo - numero- tiempo que tarda la bala en ir del punto A al B
************************************************

************************************************
************Generar Efecto Grito
************************************************
******DEFINICION************
GenerarEfectoGrito(modelo)
******DESCRIPCION************
Efecto similar al gruñido de PK B/N. Se destruye solo pasados unos pocos segundos.
******VARIABLES************
modelo - Modelo - modelo donde se spawnea el efecto que debe tener un primary part
************************************************

***********************************************
************LIMPIAR EFECTOS
************************************************
******DEFINICION************
LimpiarEfectos(modelo)
******DESCRIPCION************
Borra TODOS los efectos creados con el EffectManager que haya en el PrimaryPart de un modelo
******VARIABLES************
Model - model - un model que tenga un PrimaryPart seteado
************************************************

************************************************
************LIMPIAR EFECTOS WORKSPACE
************************************************
******DEFINICION************
LimpiarEfectosWorkspace()
******DESCRIPCION************
Borra TODOS los efectos creados con el EffectManager que haya en el Workspace
************************************************


]]
