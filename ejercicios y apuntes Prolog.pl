%logico 08-08-2019

/*estaQuemado(Repartidor): si trabaja en mas de una zona grande O (trabaja con todas las empresas y es el unico que trabajo en una zona)
tieneCobertura(Empresa): tiene repartidores en todas las zonas
careta(Empresa): solo tiene repartidores en zonas caras
explotadora(Empresa): si tiene algun empleado en bici en alguna zona grande O tiene un unico repartidor para todas las zonas que cubre
monopolio(Empresa, Zona): si solo hay repartidores de esa empreea en dicha zona
buena(Zona): si es cara y no es grande
suertudo(Repartidor): trabaja en zonas buenas
enRegla(Empresa): no tiene empleados con moto o autos viejos (antes del 15) ni autos sin baul 
bienPensada(Empresa): (tiene empleados con auto en todas las zonas buenas donde nadie mas reparte) y (todos sus empleados van bien en todas las zonas que cubren)
vaBien(Repartidor, Zona): (si la zona es chica y el tiene bicicleta) o (si la zona es grande y tiene auto) o (si la zona es cara o si tiene moto)*/

repartidor(jose, moto(16)).
repartidor(juan, bicicleta).
repartidor(tito, auto(12,true)).

cara(recoleta).
cara(palermo).

grande(palermo).

trabajaCon(juan, globo).
trabajaCon(juan, rappi).
trabajaCon(tito, globo).

trabajaEn(tito, palermo).
trabajaEn(juan, recoleta).
trabajaEn(juan, congreso).

estaQuemado(R):-  trabajaEn(R, Z1), trabajaEn(R, Z2), Z1 \= Z2, grande(Z1), grande(Z2).
estaQuemado(R):- trabajaEn(R,Z), forall(trabajaCon(_, E), trabajaCon(R,E)), not( (trabajaEn(O,Z), R\=O) ).

tieneCobertura(E):-  trabajaCon(_, E), forall(trabajaEn(_,Z), (trabajaEn(R,Z), trabajaCon(R,E)) ).

careta(E):- trabajaCon(_, E), forall(trabajaCon(R, E), forall(trabajaEn(R,Z), cara(Z)) ). %esta es la condicion correcta, que es muy diferente a esta de abajo:
caretaMAL(E):- trabajaCon(_, E), forall(trabajaCon(R, _), (trabajaCon(R,E),trabajaEn(R,Z), cara(Z)) ). 
%importante darse cuenta la diferencia entre estas dos condiciones, la direfencia es que en la que esta mal, lo que hace es que para todos los repartidores, se fija que se cunple que
%trabajen en esa empresa, que trabajen en una zona y que esa zona sea cara, pero puede pasar que ese repartidor tambien haga una que no sea cara y el condicional va a entrar igual
%porque ahi solo busca que se cumple al menos uno.
%en cambio en el que esta bien lo que hace es que se cumpla que para los trbajadores que trabajan en esa empresa, todas las zonas que hagan, tienen que ser caras, el unico detalle es que
%si un repartidor labura en otra empresa y hace para la otra empresa, una zona que no es cara, ya no lo va a considerar debido a que no se contempla que zona hace cada repaetidor par cada 
%empresa, es decir que en este caso para que se cumpla, los repartidores tienen que hacer solo zonas caras y no solo para esa empresa.
%otro ejemplo del primer ejemplo(el de los forall anidados) hecho con not seria:
caretaConNot(E):- not((trabajaCon(R,E), trabajaEn(R,Z), not(cara(Z)))).
%que es como decir que no se cumple que haya un repartidor que trabaje para esa empresa y que haga una zona que no sea cara.

explotadora(E):- grande(Z), trabajaEn(R,Z), trabajaCon(R,E), repartidor(R, bicicleta).
explotadora(E):- forall( (trabajaEn(R1,Z), trabajaCon(R1,E)) , (trabajaEn(R2, Z), R1==R2, trabajaCon(R2,E)) ).
%en realidad dijo que otra forma seria hacer esto:
explotadora2(E):- forall( (trabajaEn(R1,Z), trabajaCon(R1,E)) , not( (trabajaEn(R2, Z), R1\=R2, trabajaCon(R2,E)) ) ).

/*
monopolio(Empresa, Zona): si solo hay repartidores de esa empresa en dicha zona
monopolio(E,Z):- para todos los repartidores de esa empresa y en esa zona, se cumple que no hay otro repartidor de otra empresa que trabaje en esa zona
monopolio(E,Z):- forall(trabajaCon(R,E),trabajaEn(R,Z) , (not ((trabajaCon(R2,E2),trabajaEn(R2,Z),R2\=R, E\=E2)) ).
*/
monopolio(E,Z):- trabajaCon(R1,E), trabajaEn(R1,Z), forall(trabajaEn(R,E), trabajaCon(R,E)).

buena(Z):- cara(Z), not(grande(Z)).

suertudo(R):- not( (trabajaEn(R,Z), not(buena(Z)) ) ).

enRegla(E):- trabajaCon(_,E), not( (trabajaCon(R,E), repartidor(R,V), enFalta(V)) ).
%tambien podria poner enFalta(R) pero directament elo puso asi porque se ahorra pasos en enFalta
enFalta(moto(A)):- A<15.
enFalta(auto(A,_)):- A<15.
enFalta(auto(_,no)). 
%con la bici no pone nada porque la bici nunca esta en falta

%bienPensada(E):- forall(--zonas buenas donde nadie mas reparte, --ellos tienen a alguien con auto)
bienPensada(E):- trabajaCon(_,E), forall( (buena(Z), monopolio(E,Z)) , (trabajaEn(R,Z), trabajaCon(R,E), repartidor(R,auto(_,_))) ), not( (trabajaCon(O,E),trabajaEn(0,Z1),vaBien(O,Z1)) ).
%en este caso para no repetir el codigo pusimos monopoplio, pero conceptualmente no esta bien porque si algun dia se cambia el predicado  monopolio, 
%esto afectaria a este predicado, lo odeal seria copiar y pegar el codigo de monopolio ahi, cosa de que por mas que estsemos repitiendo codigo, 
%nos salva de futuros problemas en caso de cambiar el predicado monopolio.

vaBien(R,Z):- not( (grande(Z)) ), repartidor(R,bicicleta).
vaBien(R,Z):- grande(Z), repartidor(R,auto(_,_)).
vaBien(_,Z):- cara(Z).
vaBien(R,_):- repartidor(R,moto(_)).

/*Un Ejemplo que esta bueno es:
si estas usando un findall y luego un member, estas haciendo algo mal, debido a que se podria simplificar de otra manera
por ejemplo si te pregunto como se si una persona es hija de un tipo teniendo el predicado padre(p,h)
se podria poner asi: hijo(h,p):- padre(p,h)
en vez de crear una lista de hijos de ese padre con findall y fijarse si ese hijo esta en esa lista con un member
*/


%---------------------------------------------------------------------------------------------------------------------------%

votos(pps, caba, 750450).
votos(pps, bsas, 900302).
votos(pps, jujuy, 43725).
votos(pps, salta, 35879).
votos(pps, cordoba, 580493).
votos(pps, entreRios, 47980).
votos(pps, corrientes, 158394).
votos(pps, misiones, 120865).
votos(pps, laRioja, 236583).
votos(pps, chaco, 89402).
votos(pps, neuquen, 130385).
votos(pps, rioNegro, 106097).

votos(lcd, caba, 730750).
votos(lcd, bsas, 1000243).
votos(lcd, jujuy, 44525).
votos(lcd, salta, 30073).
votos(lcd, cordoba, 481457).
votos(lcd, entreRios, 43910).
votos(lcd, corrientes, 198594).
votos(lcd, misiones, 187843).
votos(lcd, laRioja, 223509).
votos(lcd, formosa, 79542).
votos(lcd, neuquen, 150975).
votos(lcd, sanJuan, 122397).

votos(plis, caba, 930180).
votos(plis, bsas, 990398).
votos(plis, formosa, 41024).
votos(plis, salta, 17872).
votos(plis, laPampa, 10483).
votos(plis, sanJuan, 97960).

votos(dlg, caba, 250470).
votos(dlg, bsas, 30372).
votos(dlg, jujuy, 173794).
votos(dlg, salta, 66879).
votos(dlg, cordoba, 51493).
votos(dlg, entreRios, 40450).
votos(dlg, corrientes, 238604).
votos(dlg, misiones, 240811).
votos(dlg, laRioja, 296560).
votos(dlg, sanJuan, 81478).
votos(dlg, neuquen, 180320).
votos(dlg, laPampa, 158327).

padron(caba, 2891970). 
padron(bsas, 3221085).
padron(jujuy, 282034).
padron(salta, 150703).
padron(cordoba, 1513487).
padron(entreRios, 132340).
padron(corrientes, 795592).
padron(misiones, 549519).
padron(laRioja, 756652).
padron(chaco, 98402).
padron(neuquen, 471680).
padron(rioNegro, 106097).
padron(formosa, 120566).
padron(sanJuan, 301835).
padron(laPampa, 168810).


/*
Tenemos en la base de conocimientos información sobre cuántos votos sacó cada partido político en las distintas provincias del país mediante un predicado votos/3
que relaciona al partido con la provincia y los votos conseguidos en esa provincia.
Definir un predicado votosTotales/2 para saber cuántos votos sacó un partido a nivel nacional.
*/
votosTotales(Partido, VotosTotales):- votos(Partido, _, _), findall(Votos, votos(Partido, _, Votos) , ListaVotos), sumlist(ListaVotos, VotosTotales).


/*
Definir un predicado decidida/1 que se cumple para una provincia si un único partido sacó muchos votos(porque más del 30% de los empadronados de esa provincia lo votaron).
Al igual que en el ejercicio anterior tenemos un predicado votos/3 para saber cuántos votos consiguió un partido en una provincia. 
Además también hay un predicado padron/2 que relaciona una provincia con la cantidad de personas empadronadas.
*/
decidida(Provincia):- padron(Provincia, _), votos(Partido, Provincia, _), sacoMasDelTreinta(Partido, Provincia), not( (sacoMasDelTreinta(OtroPartido, Provincia), Partido \= OtroPartido) ).

sacoMasDelTreinta(Partido, Provincia):- votos(Partido, _, _), votos(_, Provincia, _), votos(Partido, Provincia, CantidadVotos), padron(Provincia, CantidadPadron), TreintaPorcientoDelPadron is 0.3* CantidadPadron, CantidadVotos > TreintaPorcientoDelPadron.

%---------------------------------------------------------------------------------------------------------------------------%

precio(asado,450).
precio(hamburguesa,350).
precio(papasFritas,220).
precio(ensalada,190).
precio(revueltoGramajo, 220).
precio(tresEmpanadas, 120).
precio(pizza, 250).

leGusta(pepe, pizza).
leGusta(pipo, pizza).
leGusta(tito, pizza).
leGusta(toto, pizza).
leGusta(tato, pizza).
leGusta(pepe, revueltoGramajo).
leGusta(pepe, hamburguesa).
leGusta(pipo, ensalada).
leGusta(tito, hamburguesa).
leGusta(tito, tresEmpanadas).
leGusta(toto, papasFritas).
leGusta(tato, papasFritas).
leGusta(tito, papasFritas).
leGusta(pepe, papasFritas).
leGusta(pipo, papasFritas).

/*
Nuevamente tenemos en nuestra base de conocimientos información sobre los precios de las comidas del menú de un bar (mediante un predicado precio/2)
y los gustos de las personas (mediante un predicado leGusta/2).
Definir los siguientes predicados:
    masBarata/2 que relaciona dos comidas si la primera es más barata que la segunda.
    comidaPopular/1 que se cumple para una comida si le gusta a todas las personas o si es la más barata de todas las comidas del menú.
*/

comida(Comida):- precio(Comida, _).
persona(Persona):- leGusta(Persona, _).

masBarata(Comida1, Comida2):- precio(Comida1, Precio1), precio(Comida2, Precio2), Precio1 < Precio2.

esLaMasBarata(Comida):- precio(Comida, PrecioComida), forall(precio(_, PrecioComidaS), PrecioComida =< PrecioComidaS).

comidaPopular(Comida):- comida(Comida), forall(persona(Persona), leGusta(Persona, Comida)).
comidaPopular(Comida):- esLaMasBarata(Comida).

%---------------------------------------------------------------------------------------------------------------------------%


%Un conocido biólogo nos pide un programa para ayudarlo a organizar la información que recolectó sobre los animales de una isla. 
%Contamos para esto con la siguiente base de conocimiento de ejemplo:

% Identifica los animales que hay en la isla.
% animal(animal)
% los animales pueden ser átomos, functores 
% reptil(nombre) o ave(nombre,tamaño).
animal(ave(lechuza, enana)).
animal(reptil(cocodrilo)).
animal(reptil(tortugaGigante)).
animal(alpaca).
animal(ave(condor, gigante)).
animal(ave(aguila, gigante)).
animal(capibara).

% come(Depredador, Presa)
come(capibara, plantas).
come(alpaca, plantas).
come(ave(lechuza,enana), raton).
come(reptil(cocodrilo), ave(_,_)).

 
/*Teniendo en cuenta la base de conocimiento planteada, se pide resolver los siguientes puntos, asegurándose de implementar todos los predicados que se piden de modo
que sean completamente inversibles. Recuerden que no está permitido el uso de OR (;), CUT (!) y que los usos de findall/3 deben ser restringidos 
a las situaciones donde es indispensable.

1.	Indicar, justificando, si las sentencias de ejemplo dadas para el predicado come/2 permiten que este sea inversible y, en caso de no serlo, 
    dar ejemplos de las consultas que NO podrían realizarse y corregir la implementación para que se pueda.

2.
a. carnívoro/1: Se cumple para los animales que comen al menos dos animales distintos (independientemente de si comen o no otras cosas).
b. herbívoro/1: Se cumple para los animales que comen plantas pero no otros animales.
3. simbiosis/2: Relaciona dos animales si ambos se comen a algún animal que se come al otro, pero no se comen mutuamente.

4.	condenado/1: Decimos que un animal está condenado si se cumple para él cualquiera de los siguientes escenarios:
a.	Si no es herbívoro y no hay en la isla ninguno de los animales que él come.
b.	Si sólo come reptiles y aves gigantes.
c.	Si más de la mitad de los animales de la isla se lo comen.

5.	
a.	cadenaAlimenticia/2: Relaciona a un animal con otro que está debajo de él en la cadena alimenticia. Esto se da cuando el primero se come al segundo 
    o a alguien que está por encima del segundo en la cadena alimenticia.
b.	reyDeLaSelva/1: Un animal es el rey de la selva si está por encima de todos los otros animales de la isla en la cadena alimenticia y nadie se lo come a él.*/























