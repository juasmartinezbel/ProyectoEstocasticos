# DecisionTriiT

# Routes

## GET /nodes

Me renderiza el arbol a como está ahora
Si no hay nodos me responderá con el siguiente json
```json
{
    "message": "There is no nodes"
}
```

## POST /nodes
Me crea un nuevo nodo que debe tener el formato
```json
{
	"name": "string",
	"parent": "integer",
	"gain": "number",
	"probability": "number"
}
```
Ejemplo
```json
{
	"name": "Hay Leche",
	"parent": 1,
	"gain": 12,
	"probability": 40.5
}
```

Si probability es null, entonces es opción arbitraria.
Si tiene gain, se considera fin de rama, y dicha rama NO DEBERÁ tener hijos

### EL NODO INICIAL DEBERÁ TENER EL FORMATO
```json
{
	"name": "string",
	"parent": null,
	"gain": null,
	"probability": null
}
```

## DELETE /nodes/:id
Me borra el nodo de la id indicada.
Si el nodo no es una hoja, saldrá el mensaje de error:
```json
{
    "Error": "This node can't be deleted"
}
```
Si el nodo no existe, saldrá el mensaje de error:
```json
{
    "Error": "This node doesn't exist. You sure you put the id of the Node and not the one from the database?"
}
```
## PUT /nodes/:id
Me actualiza el nodo que necesito, los valores que acepta cambios son:
```json
{
	"name": "string",
	"parent": "integer",
	"gain": "number",
	"probability": "number"
}
```


## GET /results
Me obtiene los resultados del arbol SOLO si está completo
Retornandome:
```json
{
    "Dilema": "¿A Qué tienda debo ir?", //La pregunta general del problema
    "Option": "Tienda A", 	//La ṕrimera opción más factible
    "Route": "[0, 1]",		//La ruta ideal
    "Gain": "-23.6"			//El beneficio
}
```

## GET /clear
Me borra todo el arbol.

## GET /can

```json
{
    "Nodes": [1, 2]
}
```