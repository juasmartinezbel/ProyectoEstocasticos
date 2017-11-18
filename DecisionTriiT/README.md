# Decision TriiT

En esta aplicación hay tres archivos principales, además de los básicos como routes y otros:

## DecisionTriiT/app/welcomes_controller.rb
```ruby
Este es el controlador de la aplicación y tiene 3 funciones fundamentales
    def index
    def clear
    def add
```
## DecisionTriiT/app/views/welcomes/index.html.erb

```HTML
Se basa en dos <div> por el momento. "my_list" y "my_form" 
<div id="my_list"> busca que se muestren los nodos ya creados

<div id="my_form"> que crea el formulario para los componentes de la variable @hash creada en el anterior documento.
Este <div> se conecta con el archivo welcomes.coffee para que se actualice automaticamente.

A su vez, este form tiene dos fases:
1. Cuando se entra a la página por primera vez, solo se puestra un texto y un botón, esto representa un nodo origen donde se debe colocar la pregunta general del sistema.
2. Cuando se crea el nodo origen, salen más opciones
    - Add Scenario: La decisión que se presenta en el momento, solo es un título y no afecta.
    - Add Parent: Añadir uno de los NODOS que pueden ser padres
    - Was My Choice: Si llegué a este nodo por decisión propia o fue probabilidad aleatoria (Es decir, que fue tomar el trabajo 1, ir a la tienda, etc. y no que bajara el dolar, perder el concurso, que haya trancón, entre otras.)
    - Probability to here: La probabilidad de llegar a ese nodo desde el padre. En caso de que sea decisión propia se igualará a 1.
    - Gain: Ganancias que presenta este nodo. Con esto ya se considera una hoja y no podrán añadirsele hijos

```
## DecisionTriiT/app/assets/javascript/welcomes.coffee
```
    Funciones coffeescript que manejan JQuery
```
Se inicia únicamente con http://localhost:3000