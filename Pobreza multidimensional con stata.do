clear all
use "C:\Users\MilenaMaliotti\Google Drive\FCE\Estructura social\Monografia\Bases\arg20s2_base_INDEC.dta"
set more off

*Variables de sexo
rename ch04 sexo
recode sexo (2=0)
gen sexo_aux=.
replace sexo_aux=5 if sexo==1
replace sexo_aux=6 if sexo==0
*Variables de edad
rename ch06 edad
tab edad
recode edad (-1=.)
/*Grupos etarios
gen grupo_edad=.
replace grupo_edad=1 if edad>=0 & edad<=12
replace grupo_edad=2 if edad>=13 & edad<=25
replace grupo_edad=3 if edad>=26 & edad<=59
replace grupo_edad=4 if edad>=60 & edad<=111
*/
egen id= group(codusu nro_hogar)
drop if nro_hogar==51 | nro_hogar==71
keep if trimestre==4

********************************************************************************
						***Pobreza multidimensional***

*DIMENSION VIVIENDA:
*Vivienda: precariedad de los materiales.
rename iv1 tipo_viv
tab tipo_viv, m
rename iv3 piso
tab piso, m
rename v4 techo
tab techo, m
rename iv5 cielorraso
tab cielorraso, m

gen nbi1=.
replace nbi1=0 if piso==1 | piso==2 | techo==1 | techo==2 | techo==3 | (techo==4 & cielorraso==1) | (techo==5 & cielorraso==1) 
replace nbi1=1 if piso==3 | (techo==4 & cielorraso==2) | (techo==5 & cielorraso==2) | techo==6 | techo==7
egen nbi1_hog = total(nbi1), by(id) missing
replace nbi1_hog=1 if nbi1_hog!=0 & nbi1_hog!=.

*Hacinamiento: hogares que tuvieran 3 o más personas por cuarto.
rename ix_tot miembros
rename iv2 ambientes
tab miembros
tab ambientes

gen aux=miembros/ambientes

gen nbi2=.
replace nbi2=0 if aux!=.
replace nbi2=1 if aux>=3 & aux!=.
drop aux
egen nbi2_hog = total(nbi2), by(id) missing
replace nbi2_hog=1 if nbi2_hog!=0 & nbi2_hog!=.

*Tenencia insegura: el hogar ocupa la vivienda sin permiso, o bien sólo es propietario de la vivienda (y no del terreno).
rename ii7 tenencia
tab tenencia, m

gen nbi3=.
replace nbi3=1 if tenencia==2 | tenencia==7
replace nbi3=0 if tenencia==1 | tenencia==3 | tenencia==4 | tenencia==5 | tenencia==6 | tenencia==8
egen nbi3_hog = total(nbi3), by(id) missing
replace nbi3_hog=1 if nbi3_hog!=0 & nbi3_hog!=.

*TOTAL DIMENSIÓN VIVIENDA.
*Personas
gen nbi_viv_p=0
replace nbi_viv_p=1 if nbi1==1 | nbi2==1 | nbi3==1
replace nbi_viv_p=0 if nbi1==. & nbi2==. & nbi3==.
tabstat nbi_viv_p nbi1 nbi2 nbi3[w=pondera], m
*Hogares
gen nbi_viv_h=0
replace nbi_viv_h=1 if nbi1_hog==1 | nbi2_hog==1 | nbi3_hog==1
replace nbi_viv_h=0 if nbi1_hog==. & nbi2_hog==. & nbi3_hog==.
tabstat nbi_viv_h nbi1_hog nbi2_hog nbi3_hog[w=pondera] if ch03==1, m


*DIMENSION HABITAT Y SERVICIOS BASICOS:
*Condiciones sanitarias: hogares que no tuvieran ningún tipo de retrete con descarga de agua.
rename iv10 baño_descarga
tab baño_descarga, m

gen nbi4=.
replace nbi4=0 if baño_descarga==1
replace nbi4=1 if baño_descarga==2 | baño_descarga==3
egen nbi4_hog = total(nbi4), by(id) missing
replace nbi4_hog=1 if nbi4_hog!=0 & nbi4_hog!=.

*Vivienda en zona vulnerable.
rename iv12_3 villa
tab villa, m
rename iv12_1 basural
tab basural, m

gen nbi5=.
replace nbi5=1 if villa==1 | basural==1
replace nbi5=0 if villa!=1 & basural!=1
egen nbi5_hog = total(nbi5), by(id) missing
replace nbi5_hog=1 if nbi5_hog!=0 & nbi5_hog!=.

*TOTAL DIMENSIÓN HABITAT Y SERVICIOS.
*Hogares
gen nbi_hab_h=0
replace nbi_hab_h=1 if nbi4_hog==1 | nbi5_hog==1
replace nbi_hab_h=. if nbi4_hog==. & nbi5_hog==.
tabstat nbi_hab_h nbi4_hog nbi5_hog [w=pondera] if ch03==1, m
*Personas
gen nbi_hab_p=0
replace nbi_hab_p=1 if nbi4==1 | nbi5==1
replace nbi_hab_p=. if nbi4==. & nbi5==.
tabstat nbi_hab_p nbi4 nbi5 [w=pondera], m


*DIMENSION EDUCACION:
*Inasistencia escolar: niño en edad escolar (4 a 17 años) que no asista a la escuela.
*Niños que no asisten
rename ch10 asiste
recode asiste (0=.)
tab asiste, m

gen nbi6=.
replace nbi6=0 if (edad>=4 & edad<=17) & asiste==1
replace nbi6=1 if (edad>=4 & edad<=17) & (asiste==2 | asiste==3)
egen nbi6_hog = total(nbi6), by(id) missing
replace nbi6_hog=1 if nbi6_hog!=0 & nbi6_hog!=.

*Rezago escolar: diferencia de dos años entre la edad del niño/a o adolescente y la edad teórica correspondiente al año o grado al que asiste.
*Jardin -> no hay, primaria -> hasta 14 años, secundaria -> hasta 20 años
*CH12: nivel más alto qeu cursa
tab ch12 if asiste==1 & edad>=14 & edad!=.
tab ch12 if asiste==1 & edad>=19 & edad!=.
*chequemos escolaridad para EGB y polimodal:
tab ch14 if asiste==1 & ch12==3 & edad>=14 & edad!=.
tab ch14 if asiste==1 & ch12==5 & edad>=14 & edad!=.
tab ch14 if asiste==1 & ch12==3 & edad>=19 & edad!=.
tab ch14 if asiste==1 & ch12==5 & edad>=19 & edad!=.
*hay casos de personas que cursan el polimodal o EGB con rezago

gen nbi7=.
replace nbi7=1 if asiste==1 & edad>=14 & ch12==2 & edad!=.
replace nbi7=1 if (asiste==1 & ch12==3) & edad>=14 & (ch14==5 | ch14==6) & edad!=.
replace nbi7=1 if asiste==1 & edad>=19 & (ch12==2 | ch12==3 | ch12==4 | ch12==5) & edad!=.
replace nbi7=0 if asiste==1 & (edad>=2 & edad<=6) & ch12==1
replace nbi7=0 if asiste==1 & (edad>=5 & edad<=13) & ch12==2
replace nbi7=0 if asiste==1 & (edad>=11 & edad<=18) & ch12==4
replace nbi7=0 if asiste==1 & edad>=17 & (ch12==6 | ch12==7 | ch12==8)
replace nbi7=0 if asiste==1 & (edad>=12 & edad<=18) & ch12==5
replace nbi7=0 if asiste==1 & ch12==9
egen nbi7_hog = total(nbi7), by(id) missing
replace nbi7_hog=1 if nbi7_hog!=0 & nbi7_hog!=.

*Educacion insuficiente: no haber terminado el nivel educativo plasmado como obligatorio.
gen nbi8=.
replace nbi8=1 if asiste==2 & (edad>=18 & edad<=28) & (nivel_ed==1 | nivel_ed==2 | nivel_ed==3 | nivel_ed==7)
replace nbi8=1 if asiste==2 & (edad>=29 & edad!=.) & (nivel_ed==1 | nivel_ed==7)
replace nbi8=1 if asiste==3 & (edad>=18 & edad<=28)
replace nbi8=0 if (edad>=19 & edad!=.) & (nivel_ed>=4 & nivel_ed<=6)
replace nbi8=0 if (edad>=29 & edad!=.) & (nivel_ed>=2 & nivel_ed<=6)
egen nbi8_hog = total(nbi8), by(id) missing
replace nbi8_hog=1 if nbi8_hog!=0 & nbi8_hog!=.

*TOTAL DIMENSIÓN EDUCACIÓN.
*Hogares
gen nbi_edu_h=0
replace nbi_edu_h=1 if nbi6_hog==1 | nbi7_hog==1 | nbi8_hog==1
replace nbi_edu_h=. if nbi6_hog==. & nbi7_hog==. & nbi8_hog==.
tabstat nbi_edu_h nbi6_hog nbi7_hog nbi8_hog [w=pondera] if ch03==1, m
*Personas
gen nbi_edu_p=0
replace nbi_edu_p=1 if nbi6==1 | nbi7==1 | nbi8==1
replace nbi_edu_p=. if nbi6==. & nbi7==. & nbi8==.
tabstat nbi_edu_p nbi6 nbi7 nbi8 [w=pondera], m


*DIMENSION EMPLEO Y PROTECCIÓN SOCIAL:
*Dificultades de acceder a empleo remunerado.
tab estado
tab pp02e
recode pp02e (0=.)
recode sexo (2=0)

gen nbi9=.
replace nbi9=1 if (edad>=16 & edad<=59) & sexo==0 & ((estado==2) | (pp02e==3 | pp02e==5))
replace nbi9=1 if (edad>=16 & edad<=64) & sexo==1 & ((estado==2) | (pp02e==3 | pp02e==5))
replace nbi9=0 if  (edad>=16 & edad<=59) & sexo==0 & ((estado==1 | estado==3) | (pp02e==1 | pp02e==2 | pp02e==4))
replace nbi9=0 if  (edad>=16 & edad<=64) & sexo==1 & ((estado==1 | estado==3) | (pp02e==1 | pp02e==2 | pp02e==4))
egen nbi9_hog = total(nbi9), by(id) missing
replace nbi9_hog=1 if nbi9_hog!=0 & nbi9_hog!=.

*Precariedad laboral.
/*
Considera a toda aquella persona ocupada que no es un asalariado registrado,
patrón o empleador, trabajador por cuenta propia de calificación profesional o
técnica; dejando, así como padeciendo privación a los trabajadores por cuenta
propia de calificación operativa o carentes de calificación (de los que se presume
que no realizan aportes a la seguridad social), a los asalariados no registrados y al
personal de servicio doméstico.
*/
gen nbi10=.
replace nbi10=1 if cat_ocup==2 & (nivel_ed<=3 | nivel_ed==7)
replace nbi10=1 if pp07i==2 | pp07h==2
replace nbi10=1 if pp04b1==1 & (pp07i==2 & pp07h==2)
replace nbi10=0 if cat_ocup==2 & (nivel_ed>=4 & nivel_ed<=6)
replace nbi10=0 if pp07i==1 | pp07h==1
replace nbi10=0 if pp04b1==1 & (pp07i==1 | pp07h==1)
egen nbi10_hog = total(nbi10), by(id) missing
replace nbi10_hog=1 if nbi10_hog!=0 & nbi10_hog!=.

*Cobertura previsional.
*v2_m: monto percibido por jubilacion/pension
recode v2_m (-9=.)

gen nbi11=.
replace nbi11=0 if (edad>=65 & edad!=. & sexo==1) & v2_m>=0 & v2_m!=.
replace nbi11=0 if (edad>=60 & edad!=. & sexo==0) & v2_m>=0 & v2_m!=.
replace nbi11=1 if (edad>=65 & edad!=. & sexo==1) & v2_m==0 & v2_m!=.
replace nbi11=1 if (edad>=60 & edad!=. & sexo==0) & v2_m==0 & v2_m!=.
egen nbi11_hog = total(nbi11), by(id) missing
replace nbi11_hog=1 if nbi11_hog!=0 & nbi11_hog!=.

*TOTAL DIMENSION EMPLEO Y PROTECCIÓN SOCIAL.
*Hogares
gen nbi_lab_h=0
replace nbi_lab_h=1 if nbi9_hog==1 | nbi10_hog==1 | nbi11_hog==1
replace nbi_lab_h=. if nbi9_hog==. & nbi10_hog==. & nbi11_hog==.
tabstat nbi_lab_h nbi9_hog nbi10_hog nbi11_hog [w=pondera] if ch03==1, m
*Personas
gen nbi_lab_p=0
replace nbi_lab_p=1 if nbi9==1 | nbi10==1 | nbi11==1
replace nbi_lab_p=. if nbi9==. & nbi10==. & nbi11==.
tabstat nbi_lab_p nbi9 nbi10 nbi11 [w=pondera], m


*DIMENSION SALUD:
*Ausencia de doble cobertura de salud.
rename ch08 salud
recode salud (9=.)

gen nbi12=.
replace nbi12=1 if salud==4
replace nbi12=0 if salud!=4 & salud!=.
egen nbi12_hog = total(nbi12), by(id) missing
replace nbi12_hog=1 if nbi12_hog!=0 & nbi12_hog!=.

*TOTAL DIMENSIÓN SALUD.
*Hogares
gen nbi_salud_h=0
replace nbi_salud_h=1 if nbi12_hog==1
replace nbi_salud_h=. if nbi12_hog==.
tabstat nbi_salud_h [w=pondera] if ch03==1, m
*Personas
gen nbi_salud_p=0
replace nbi_salud_p=1 if nbi12==1
replace nbi_salud_p=. if nbi12==.
tabstat nbi_salud_p [w=pondera], m


*EXPORTACIÓN DE RESULTADOS:
mat resultados=J(16,2,.)
forvalues i=1(1)12 {
sum nbi`i'_hog [w=pondera] if ch03==1
mat resultados[`i',1]=r(mean)
}
forvalues i=1(1)12 {
sum nbi`i' [w=pondera]
mat resultados[`i',2]=r(mean)
}
mat li resultados
*****
matrix colnames resultados = Hogares Personas
matrix rownames resultados = nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15 pob_multidimensional
mat li resultados


********************************************************************************

*TECNOLOGIAS:
/*
clear all
import delimited "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\EPH_usu_hog_tic_T420.txt", delimiter(";") 
save "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\TIC_hogar.dta"
clear all
import delimited "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\EPH_usu_indiv_tic_T420.txt", delimiter(";") 
save "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\TIC_indiv.dta"
merge m:m codusu nro_hogar using "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\TIC_hogar.dta"
drop _merge
save "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\TIC_completa.dta"
*/
merge m:m codusu nro_hogar trimestre using "C:\Users\camih\Google Drive\FCE\03_Estructura social\Monografia\Bases\TIC_completa.dta"
drop if _merge==2

*DIMENSIÓN TECNOLOGÍA.
*Computadoras:
tab ih_ii_01 if _merge==3, m
gen nbi13=.
replace nbi13=0 if ih_ii_01==1 & _merge==3
replace nbi13=1 if ih_ii_01==2 & _merge==3
egen nbi13_hog = total(nbi13), by(id) missing
replace nbi13_hog=1 if nbi13_hog!=0 & nbi13_hog!=.

*Internet:
tab ih_ii_02 if _merge==3, m
gen nbi14=.
replace nbi14=0 if ih_ii_02==1 & _merge==3
replace nbi14=1 if ih_ii_02==2 & _merge==3
egen nbi14_hog = total(nbi14), by(id) missing
replace nbi14_hog=1 if nbi14_hog!=0 & nbi14_hog!=.

*Celulares:
tab ip_iii_06 if _merge==3, m
gen nbi15=.
replace nbi15=0 if ip_iii_06==1 & _merge==3
replace nbi15=1 if ip_iii_06==2 & _merge==3
egen nbi15_hog = total(nbi15), by(id) missing
replace nbi15_hog=1 if nbi15_hog!=0 & nbi15_hog!=.

*TOTAL DIMENSIÓN TECNOLOGÍA.
*Hogares
gen nbi_tec_h=0
replace nbi_tec_h=1 if nbi13_hog==1 | nbi14_hog==1 | nbi15_hog==1
replace nbi_tec_h=. if nbi13_hog==. & nbi14_hog==. & nbi15_hog==.
tabstat nbi_tec_h  nbi13_hog nbi14_hog nbi15_hog[w=pond_tic] if ch03==1, m
*Personas
gen nbi_tec_p=0
replace nbi_tec_p=1 if nbi13==1 | nbi14==1 | nbi15==1
replace nbi_tec_p=. if nbi13==. & nbi14==. & nbi15==.
tabstat nbi_tec_p nbi13 nbi14 nbi15 [w=pond_tic], m


*RESULTADOS
forvalues i=13(1)15 {
sum nbi`i'_hog [w=pond_tic] if ch03==1
mat resultados[`i',1]=r(mean)
}
forvalues i=13(1)15 {
sum nbi`i' [w=pond_tic]
mat resultados[`i',2]=r(mean)
}
mat li resultados
*****
matrix colnames resultados = Hogares Personas
matrix rownames resultados = nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15 pob_multidimensional
mat li resultados

********************************************************************************

/*
POBREZA: si un hogar presenta privaciones al menos dos indicadores,
se lo considera en situacion de pobreza.
*/
*Personas
egen total_pob_p = rowtotal(nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15), missing
*br total_pob nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15
gen pob_multi_p=0
replace pob_multi_p=1 if total_pob_p>=2
replace pob_multi_p=. if total_pob_p==.
tabstat pob_multi_p [w=pondera]

*Hogares
egen total_pob_h = rowtotal(nbi1_hog nbi2_hog nbi3_hog nbi4_hog nbi5_hog nbi6_hog nbi7_hog nbi8_hog nbi9_hog nbi10_hog nbi11_hog nbi12_hog nbi13_hog nbi14_hog nbi15_hog) if ch03==1, missing
*br total_pob nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15
gen pob_multi_h=0
replace pob_multi_h=1 if total_pob_h>=2
replace pob_multi_h=. if total_pob_h==.
tabstat pob_multi_h [w=pondera] if ch03==1


*RESULTADO
sum pob_multi_h [w=pondera] if ch03==1
mat resultados[16,1]=r(mean)
sum pob_multi_p [w=pondera]
mat resultados[16,2]=r(mean)
mat li resultados
*****
matrix colnames resultados = Hogares Personas
matrix rownames resultados = nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15 pob_multidimensional
mat li resultados
putexcel A1=matrix(resultados, names) using "Datos Monografía.xlsx", sheet("NBIs") modify



********************************************************************************
*Exportamos los resultados de las DIMENSIONES (no por nbi):
mat resultados_2=J(6,2,.)
*Hogares
sum nbi_viv_h [w=pondera] if ch03==1
mat resultados_2[1,1]=r(mean)
sum nbi_hab_h [w=pondera] if ch03==1
mat resultados_2[2,1]=r(mean)
sum nbi_edu_h [w=pondera] if ch03==1
mat resultados_2[3,1]=r(mean)
sum nbi_lab_h [w=pondera] if ch03==1
mat resultados_2[4,1]=r(mean)
sum nbi_salud_h [w=pondera] if ch03==1
mat resultados_2[5,1]=r(mean)
sum nbi_tec_h [w=pond_tic] if ch03==1
mat resultados_2[6,1]=r(mean)
*Personas
sum nbi_viv_p [w=pondera]
mat resultados_2[1,2]=r(mean)
sum nbi_hab_p [w=pondera]
mat resultados_2[2,2]=r(mean)
sum nbi_edu_p [w=pondera]
mat resultados_2[3,2]=r(mean)
sum nbi_lab_p [w=pondera]
mat resultados_2[4,2]=r(mean)
sum nbi_salud_p [w=pondera]
mat resultados_2[5,2]=r(mean)
sum nbi_tec_p [w=pond_tic]
mat resultados_2[6,2]=r(mean)

matrix colnames resultados_2 = Hogares Personas
matrix rownames resultados_2 = Vivienda Habitat_ssbs Educación Empleo Salud Tecnología
mat li resultados_2
putexcel A1=matrix(resultados_2, names) using "Datos Monografía.xlsx", sheet("Dimensiones") modify


********************************************************************************


*RESULTADOS NBIs en números:
set more off
mat resultados_3=J(15,2,.)
forvalues i=1(1)15 {
*Hogares
sum nbi`i'_hog [w=pondera] if nbi`i'_hog==1 & ch03==1
mat resultados_3[`i',1]=r(sum_w)
*Personas
sum nbi`i' [w=pondera] if nbi`i'==1
mat resultados_3[`i',2]=r(sum_w)
}
matrix colnames resultados_3 = Hogares Personas
matrix rownames resultados_3 = nbi1 nbi2 nbi3 nbi4 nbi5 nbi6 nbi7 nbi8 nbi9 nbi10 nbi11 nbi12 nbi13 nbi14 nbi15
mat li resultados_3
putexcel A1=matrix(resultados_3, names) using "Datos Monografía.xlsx", sheet("Tot_NBIs") modify

**********

*Exportamos Datos para el mapeo:
*Hogares
tabstat nbi_viv_h nbi_hab_h nbi_edu_h nbi_lab_h nbi_salud_h nbi_tec_h [w=pondera] if ch03==1, by(region) m
*Personas
tabstat nbi_viv_p nbi_hab_p nbi_edu_p nbi_lab_p nbi_salud_p nbi_tec_p [w=pondera], by(region) m

-










/*
*Capacidad de subsistencia: hogares que tuvieran 4 o más personas por miembro ocupado y, además, cuyo jefe tuviera baja educación (primaria incompleta).
*Generamos la variable ocupados
gen ocupado=0 if (ESTADO==2 | ESTADO==3)
replace ocupado=1 if ESTADO==1
bys id: egen n_ocupados = sum(ocupado)
gen aux_ratio=miembros/n_ocupados

gen jefe=1 if CH03==1
replace jefe=0 if CH03!=1

gen aux=0 if jefe==1 & (NIVEL_ED>=2 & NIVEL_ED<=6)
replace aux=1 if jefe==1 & (NIVEL_ED==1 | NIVEL_ED==7)
bysort id: egen edu_jefe=sum(aux)

gen nbi5=0
replace nbi5=1 if aux_ratio>=4 & edu_jefe>0
drop aux* edu_jefe

*(i) Computar el porcentaje de hogares con carencias según cada criterio
tab nbi1 [w=PONDERA] if jefe==1
tab nbi2 [w=PONDERA] if jefe==1
tab nbi3 [w=PONDERA] if jefe==1
tab nbi4 [w=PONDERA] if jefe==1
tab nbi5 [w=PONDERA] if jefe==1




*Asistencia escolar: hogares que tuvieran algún niño en edad escolar (4 a 17 años) que no asista a la escuela.
*Niños que no asisten
rename CH10 asiste
tab asiste, m

gen aux=0
replace aux=1 if (edad>=4 & edad<=17) & (asiste==2)
bys id: egen aux2=total(aux)

gen nbi6=0
replace nbi6=1 if aux2>=1 & aux2!=.
drop aux aux2



gen nbi7=.
replace nbi7=0 if asiste==1 & (edad>=2 & edad<=6) & ch12==1
replace nbi7=0 if asiste==1 & (edad>=5 & edad<=13) & ch12==2
replace nbi7=0 if asiste==1 & (edad>=11 & edad<=18) & ch12==4
replace nbi7=0 if asiste==1 & edad>=17 & (ch12==6 | ch12==7 | ch12==8)
replace nbi7=0 if asiste==1 & (edad>=12 & edad<=18) & ch12==5
replace nbi7=0 if asiste==1 & ch12==9

replace nbi7=1 if asiste==1 & edad>=14 & ch12==2
replace nbi7=1 if asiste==1 & edad>=14 & ch12==3 & ch14<=6
replace nbi7=1 if asiste==1 & edad>=19 & (ch12==2 | ch12==3 | ch12==4 | ch12==5)



********************************************************************************
matrix colnames pobreza = pobreza indigencia
matrix rownames pobreza = 0-12 13-25 26-59 +60 Hombres Mujeres TOTAL
mat li pobreza
putexcel A1=matrix(pobreza, names) using "Datos CABA_t`t'.xlsx", sheet("Pobreza") replace


