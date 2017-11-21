# DecisionTriiT

##Routes

###GET /nodes

Me renderiza el arbol a como está ahora


###POST /nodes
Me crea un nuevo nodo que debe tener el formato
```json
{
	"name": "string",
	"parent": integer,
	"gain": number,
	"probability": number
}
```
Si probability es null, entonces es opción arbitraria.
Si tiene gain, se considera fin de rama, y dicha rama NO DEBERÁ tener hijos

####EL NODO INICIAL DEBERÁ TENER EL FORMATO
```json
{
	"name": "string"
	"parent": null,
	"gain": null,
	"probability": null
}
```

###DELETE /nodes/:id
Me borra el nodo de la id indicada.

###PUT /nodes/:id
Me actualiza el nodo que necesito, los valores que acepta cambios son:
```json
{
	"name": "string",
	"parent": integer,
	"gain": number,
	"probability": number
}
```