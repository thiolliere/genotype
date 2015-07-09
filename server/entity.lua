entity = {

function genotype.newEntity()
	return {
		owner = "authority"
		shape = "rectangle"
		position = { x = 0, y = 0}
		velocity = { x = 0, y = 0}
		acceleration = { x = 0, y = 0}
		visible = true
		perception = {
			type = "rectangle"
			width = 10
			height = 10
		}
	}
end
