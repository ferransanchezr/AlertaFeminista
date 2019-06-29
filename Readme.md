# Alerta Lila | Punt lila App

l’Objectiu principal d’aquest projecte és desenvolupar una aplicació funcional que serveixi com a eina d’autodefensa i limitadora en situacions de violència  masclista.
Aquesta és una eina multiplataforma, desenvolupada a partir de Flutter i amb Firebase services.


### Instal·lació

Installació proximament disponible a Google play i App Store.


## Tests de Validació de Formularis 

Hem comprovat tots els possibles camins que hem trobat útils com: usuari i contrasenya buits,
amb caràcters especials, amb una llargària que excedeix  a la màxima permesa. També hem provat injeccions de consultes a la base de dades i de codi en javascript.

Exemple:

```
//Cas: telèfon i nom amb més caràcters dels permesos 
    await tester.showKeyboard(find.byKey(_name));
    await tester.showKeyboard(find.byKey(_phone));
    await tester.enterText(find.byKey(_name), "01234567890123989182]");
    await tester.enterText(find.byKey(_phone), '01234567890123989182');
    await tester.pump();
    expect(errorCode,"error");
```


### Estil de Codi

He utilitzat la guia d'estil de [Flutter] que podeu trobar al següent link -[Guia d'estil](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2#file-readme-template-md)



## Contruit a partir de

* [Flutter](https://flutter.dev/?gclid=CjwKCAjwmNzoBRBOEiwAr2V27RcZ-joc6BvDR-TQ7UgWesDyuBOdQCvkrM4CrHclxWcBEM5TKBKrwRoCH-0QAvD_BwE) - El Framework utilitzat
* [Firebase](https://firebase.google.com/?gclid=CjwKCAjwmNzoBRBOEiwAr2V27Y-RTXC0AAQN78_wSGmkmDxTokNxwnjtApwf3LEh7RBLywlxgmXpUhoCDScQAvD_BwE) - El Back End 


## Autors

* **Ferran Sánchez** - *Treball Inicial* - [Ferran Sánchez](https://github.com/ferransanchezr)



