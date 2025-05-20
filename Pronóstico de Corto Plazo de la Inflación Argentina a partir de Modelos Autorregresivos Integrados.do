set more off 

cd "C:\Users\MilenaMagliotti\Desktop\Facultad\EconometriaII"

use "BASE PRELIMINAR.dta"

gen mes=mofd(Período)
format %tmMon-YY mes

tsset mes

gen inflacion=(d.IPC/l.IPC)*100

drop Período

*Estacionalidad de la serie 

gen linflacion=log(inflacion)

dfsummary linflacion, trend seasonal reg

varsoc D.linflacion if mes<tm(2020m7)
*2rez 

dfuller linflacion if mes<tm(2020m7),lag(2) trend reg
*no rech ho

varsoc D2.linflacion if mes<tm(2020m7)
*2rez

dfuller D.linflacion if mes<tm(2020m7),lag(2) trend reg
*Rechazamos ho, nos quedamos con este modelo. 

tsline D.linflacion if mes<tm(2020m7)
corrgram D.linflacion if mes<tm(2020m7)
ac D.linflacion if mes<tm(2020m7)

*Vamos a modelar la serie linflacion como un AR(13)
arima linflacion if mes<tm(2020m7), arima(13,1,0)
predict e_1, res
ac e_1
corrgram e_1
*Nos quedamos con el modelo anterior para pronosticar ya que los residuos del mismo no tienen autocorrelación
predict f1,dynamic(tm(2020m7)) y
tsline f1 linflacion

*Probamos modelos alternativos
arima linflacion if mes<tm(2020m7), arima(13,1,0)
*Eliminamos L12
arima D.linflacion if mes<tm(2020m7), ar(1/11,13)
predict e_2, res
ac e_2
corrgram e_2
predict f2,dynamic(tm(2020m7)) y
estat ic


arima D.linflacion if mes<tm(2020m7), ar(1/11,13)
*Eliminamos L9
arima D.linflacion if mes<tm(2020m7), ar(1/8,10/11,13)
predict e_3, res
ac e_3
corrgram e_3
predict f3,dynamic(tm(2020m7)) y
estat ic


arima D.linflacion if mes<tm(2020m7), ar(1/8,10/11,13)
*Eliminamos L8
arima D.linflacion if mes<tm(2020m7), ar(1/7,10/11,13)
predict e_4, res
ac e_4
corrgram e_4
predict f4,dynamic(tm(2020m7)) y
estat ic



arima D.linflacion if mes<tm(2020m7), ar(1/7,10/11,13)
*Eliminamos L10
arima D.linflacion if mes<tm(2020m7), ar(1/7,11,13)

predict e_5, res
ac e_5
corrgram e_5
predict f5,dynamic(tm(2020m7)) y
estat ic


* Renombramos variables
 forvalues i=1(1)5{
 label var f`i' "Pronostico`i'
 } 
* 

tsline   f1 f2 f3 f4 f5 linflacion if mes >=tm(2020m1)


tsappend, add(4)

*Predicción 
arima D.linflacion if mes<tm(2020m7), ar(1/7,11,13)
predict p2020,dynamic(tm(2020m7)) y
label var p2020 "Pronóstico"

tsline p2020 linflacion, xlabel(#20, angle(vertical))
tsline linflacion p2020 if mes>=tm(2019m5), xlabel(#20, angle(vertical))
*tsline p2020 linflacion if mes>=tm(2020m1)  , xlabel(#12, angle(vertical))







 
