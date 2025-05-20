/*
*Abrimos las bases:
*EMAE
clear all
import excel "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\sh_emae_mensual_base2004.xls", sheet("EMAE-n° índice y variaciones")

gen mes=m(2016m12)+_n-1
format %tmMon-YY mes
tsset mes
rename B EMAE
drop A

save "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\EMAE.dta"

*IPC
clear all
import excel "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\ipc_gral.xlsx", sheet("Hoja1") firstrow

gen mes=m(2016m12)+_n-1
format %tmMon-YY mes
tsset mes

rename Nivelgeneral ipc
drop Totalnacional
keep in 1/53

save "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\IPC.dta", replace

*Tipos de cambio
clear all
import delimited "C:\Users\MilenaMagliotti\Google Drive\FCE\Econometria II\Práctica\2021\tipos-de-cambio-historicos.csv"
drop dolar_finan_esp_compra dolar_finan_esp_venta dolar_financiero_compra dolar_financiero_venta dolar_libre_compra dolar_libre_venta dolar_oficial_compra dolar_oficial_venta dolar_referencia_com_3500 dolar_tipo_unico
drop in 1/17132

gen dia=date(indice_tiempo, "YMD")
format %tdDD dia
tsset dia

drop if dia<td(31dec2016)
forvalues i=17(1)21 {
drop if dia>=td(1jan20`i') & dia<td(31jan20`i')
drop if dia>=td(1feb20`i') & dia<td(28feb20`i')
drop if dia>=td(1mar20`i') & dia<td(31mar20`i')
drop if dia>=td(1apr20`i') & dia<td(30apr20`i')
drop if dia>=td(1may20`i') & dia<td(31may20`i')
drop if dia>=td(1jun20`i') & dia<td(30jun20`i')
drop if dia>=td(1jul20`i') & dia<td(31jul20`i')
drop if dia>=td(1aug20`i') & dia<td(31aug20`i')
drop if dia>=td(1sep20`i') & dia<td(30sep20`i')
drop if dia>=td(1oct20`i') & dia<td(31oct20`i')
drop if dia>=td(1nov20`i') & dia<td(30nov20`i')
drop if dia>=td(1dec20`i') & dia<td(31dec20`i')
}
*

gen mes=m(2016m12)+_n-1
format %tmMon-YY mes
tsset mes

drop indice_tiempo dia

save "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\tipo_cambio.dta"

*Remuneracion a los trabajadores (RIPTE)
clear all
import delimited "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\remuneracion-imponible-promedio-trabajadores-estables-ripte-total-pais-pesos-serie-mensual.csv"
drop in 1/269

gen mes=m(2016m12)+_n-1
format %tmMon-YY mes
tsset mes

drop indice_tiempo

save "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\RIPTE.dta"

*M2
clear all
import excel "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\M2_2.xlsx", sheet("Hoja2")
rename B M2

gen mes=m(2016m12)+_n-1
format %tmMon-YY mes
tsset mes

drop A

save "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\M2.dta"

***Mergeo:
clear all
use "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\\2021\\EMAE.dta"
merge m:m mes using "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\IPC.dta"
drop _merge
merge m:m mes using "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\tipo_cambio.dta"
drop _merge
merge m:m mes using "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\RIPTE.dta"
drop _merge
merge m:m mes using "C:\Users\MilenaMagliotti\Google Drive\FCE\EconometriaII\Práctica\2021\M2.dta"
drop _merge

drop in 53
drop indice_tiempo dia
rename dolar_estadounidense tipodecambio
order mes
save "C:\Users\camih\Google Drive\FCE\04_Econometria II\Práctica\2021\TP2\BASE_TP2.dta", replace

*/

clear all
use "C:\Users\MilenaMagliotti\Google Drive\FCE\Econometria II\Práctica\2021\TP2\BASE_TP2.dta"
set more off

*******************
*******************
*Calculamos los logaritmos de las variables*

gen lipc=log(ipc)
gen lcambio=log(tipodecambio)
gen lEMAE=log(EMAE)
gen lripte=log(ripte)
gen lm2=log(M2)
*Graficamos*
tsline lcambio lEMAE lipc lripte lm2, xlabel(#51, angle(vertical) labsize(vsmall))

*Generamos las diferencias de los logaritmos*
xtset

foreach i of varlist lcambio lEMAE lipc lripte lm2 {
gen `i'_1=L.`i'
gen d`i'=`i'-`i'_1
}
*

*Graficamos*
tsline dlipc dlcambio dlEMAE dlripte dlm2, xlabel(#51, angle(vertical) labsize(vsmall))


*******************
*******************
*Trabajamos con la serie en diferencias de logaritmos del IPC*
*Inspección visual*
tsline dlipc, xlabel(#51, angle(vertical) labsize(vsmall))

*Si tomamos H=Septiembre-2018 - post-anuncio acuerdo con el FMI//Comienzo de la pandemia H=Marzo-2020*
foreach i in 2018m9 2020m3 {
gen dummy1=0
replace dummy1=1 if mes>=m(`i')
*Si generamos una dummy que contenga los datos del periodo previo a H:
gen dummy2=1-dummy1
*Análogamente:
reg dlipc dummy1 dummy2, nocons
*testeamos*
test dummy1-dummy2=0
*Rechazamos la hipotesis nula de que NO hay un cambio estructural*
drop dummy1 dummy2
}
*Ahora bien, si vemos que hay diferencias pero no estamos seguros -> test de Hansen*
*regresamos la diferencia de logaritmos del IPC con un rezago:
reg dlipc L.lipc
*Si queremos estimar en qué momento pudo darse el cambio estructural a partir de otro criterio, probamos con el test de Wald:
estat sbsingle
*Vemos que el cambio estructural pudo ser en Enero 2020*

********************************************************************************

*Trabajamos con la serie en diferencias de logaritmos del Tipo de Cambio*
*Inspección visual*
tsline dlcambio, xlabel(#51, angle(vertical) labsize(vsmall))

*Si tomamos H=Septiembre-2019 - Elecciones PASO//Comienzo de la pandemia H=Marzo-2020*
foreach i in 2019m9 2020m3 {
gen dummy3=0
replace dummy3=1 if mes>=m(`i')
*Si generamos una dummy que contenga los datos del periodo previo a H:
gen dummy4=1-dummy3
*Regresamos para ver los efectos de las dummys, y si efectivamente hay un cambio significativo a la izquierda y derecha de H:
reg dlcambio dummy3 dummy4, nocons
*testeamos*
test dummy3-dummy4=0
*No tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural*
drop dummy3 dummy4
}
*Si en la inspección visual vemos que hay diferencias pero no estamos seguros -> test de Hansen*
*regresamos la diferencia de logaritmos del Tipo de Cambio con un rezago:
reg dlcambio L.lcambio
*Si queremos estimar en qué momento pudo darse el cambio estructural a partir de otro criterio, probamos con el test de Wald:
estat sbsingle
*Nuevamente, no tenemos pruebas suficientes para rechazar la hipotesis nula de que no hay un cambio estructural*

********************************************************************************

*Trabajamos con la serie en diferencias de logaritmos del EMAE*
*Inspección visual*
tsline dlEMAE, xlabel(#51, angle(vertical) labsize(vsmall))

*A partir de la inspección visual no estamos seguros de cual podría ser el momento de cambio estrutural, si lo hay -> test de Hansen*
*regresamos la diferencia de logaritmos del EMAE con un rezago:
reg dlEMAE L.lEMAE
*Si queremos estimar en qué momento pudo darse el cambio estructural a partir de otro criterio, probamos con el test de Wald:
estat sbsingle
*Tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural con un 10% de significancia*

*Probamos una dummy para el período post-pandemia:
gen dummy=0
replace dummy=1 if mes>=m(2020m3)
*Si generamos una dummy que contenga los datos del periodo previo a H:
gen dummy0=1-dummy
*Regresamos para ver los efectos de las dummys, y si efectivamente hay un cambio significativo a la izquierda y derecha de H:
reg dlEMAE dummy dummy0, nocons
*testeamos*
test dummy-dummy0=0
*No tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural*
drop dummy dummy0

********************************************************************************

*Trabajamos con la serie en diferencias de logaritmos del RIPTE*
*Inspección visual*
tsline dlripte, xlabel(#51, angle(vertical) labsize(vsmall))

*A partir de la inspección visual no estamos seguros de cual podría ser el momento de cambio estrutural, si lo hay -> test de Hansen*
*regresamos la diferencia de logaritmos del RIPTE con un rezago:
reg dlripte L.dlripte
*Si queremos estimar en qué momento pudo darse el cambio estructural a partir de otro criterio, probamos con el test de Wald:
estat sbsingle
*No tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural*

*Probamos una dummy para el período post-pandemia:
gen dummy=0
replace dummy=1 if mes>=m(2020m3)
*Si generamos una dummy que contenga los datos del periodo previo a H:
gen dummy0=1-dummy
*Regresamos para ver los efectos de las dummys, y si efectivamente hay un cambio significativo a la izquierda y derecha de H:
reg dlripte dummy dummy0, nocons
*testeamos*
test dummy-dummy0=0
*No tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural*
drop dummy dummy0

********************************************************************************

*Trabajamos con la serie en diferencias de logaritmos del M2*
*Inspección visual*
tsline dlm2, xlabel(#51, angle(vertical) labsize(vsmall))

*Si tomamos H=Abril-2020//Comienzo de la pandemia H=Marzo-2020*
foreach i in 2020m4 2020m3 {
gen dummy5=0
replace dummy5=1 if mes>=m(`i')
*Si generamos una dummy que contenga los datos del periodo previo a H:
gen dummy6=1-dummy5
*Regresamos para ver los efectos de las dummys, y si efectivamente hay un cambio significativo a la izquierda y derecha de H:
reg dlm2 dummy5 dummy6, nocons
*testeamos*
test dummy5-dummy6=0
*No tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural*
drop dummy5 dummy6
}
*A partir de la inspección visual no estamos seguros de cual podría ser el momento de cambio estrutural, si lo hay -> test de Hansen*
*regresamos la diferencia de logaritmos del M2 con un rezago:
reg dlm2 L.dlm2
*Si queremos estimar en qué momento pudo darse el cambio estructural a partir de otro criterio, probamos con el test de Wald:
estat sbsingle
*No tenemos pruebas suficientes para rechazar la hipotesis nula de que NO hay un cambio estructural*


*******************
*******************
*Modelo VAR de las diferencias de los logaritmos de las variables*
*Determinamos la cantidad de rezagos para nuestro modelo*
varsoc dlipc dlcambio dlEMAE dlripte dlm2
*elegimos un rezago por criterio Akaike, el criterio Basyesiano nos sugiere cero rezagos*
*Arrojamos el modelo VAR(1)*
var dlipc dlcambio dlEMAE dlripte dlm2, lags(1)
*Utilizamos "varstable" para chequear la estabilidad del modelo*
varstable
*Vemos que los modulos son menores a 1 en valor absoluto por el criterio de los autovalores*
*Con el comando "varlmar" podemos ver la autorcorrelacion de los residuos (no deberian estar correlacionados)*
varlmar
*No podemos rechazar H0 (no autocorrelación)*
*Evaluamos la causalidad de Granger*
vargranger
*Efectivamente vemos que el IPC es explicado por el tipo de cambio y el RIPTE es explicado por el IPC*


*******************
*******************
*Armamos la matriz para mostrar el impacto*
matrix A = (1,0,0,0,0\.,1,0,0,0\.,.,1,0,0\.,.,.,1,0\.,.,.,.,1)
matrix B = (.,0,0,0,0\0,.,0,0,0\0,0,.,0,0\0,0,0,.,0\0,0,0,0,.)
*El A51 seria el impacto de los cambios en M2 (impresión de billetes) sobre el IPC*
*Estimamos los coeficientes de impacto en un modelo VAR estructural*
svar dlipc dlcambio dlEMAE dlripte dlm2, aeq(A)

matrix Aest = e(A)
matrix Best = e(B)
matrix chol_est = inv(Aest)*Best
matrix list chol_est

*Impulso respuesta*
irf create svar1, set(myIRF1,replace) step(12)
irf graph oirf, impulse(dlm2)response(dlipc) xlabel(#12)
*Podemos ver el efecto acumulado*
irf graph coirf, impulse(dlm2)response(dlipc) xlabel(#12)

*Estimamos el impacto con un modelo VAR y comparamos*
var dlipc dlcambio dlEMAE dlripte dlm2, lags(1)
irf create var1, step(12)
irf graph oirf, irf(svar1 var1) impulse(dlm2) response(dlipc) xlabel(#12)
*Veamos el fecto acumulado*
irf graph coirf, irf(svar1 var1) impulse(dlm2) response(dlipc) xlabel(#12)


*******************
*******************
*Utilizamos las series sin diferenciar, ya que queremos ver si están cointegradas*
*Elegimos los rezagos del modelo*
varsoc lipc lcambio lEMAE lripte lm2
*Tenemos UN rezago, según el criterio Bayesiano*
*Control de Cointegracion: Rango*
vecrank lipc lcambio lEMAE lripte lm2, lags(1)
*Tenemos un rango: rank(2)*
*Estimamos el modelo VEC*
vec lipc lcambio lEMAE lripte lm2, lags(1) rank(2)
*El cuadro final de Johansen nos muestra la relacion de largo plazo de las variables (no de un shock)*
*lo importante es ver la relacion de largo plazo pero no se lee como algun tipo de causalidad*

*como el EMAE y M2 no son significativos para explicar la relacion la inflación probamos lo siguiente:
varsoc lipc lcambio lripte
vecrank lipc lcambio lripte, lags(1)
vec lipc lcambio lripte, lags(1) rank(2)
*lo que genera los movimientos es no estar en el equilibrio que nos muestra el modelo VEC*
*podemos considerar algunos resultados cuando cambiamos el orden de las variables al arrojar el modelo VEC*


********************************************************************************
