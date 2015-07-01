th.graphics  : -- utilisateur

	2D:
	sprite et effect:

	les sprites sont pour tous les objets : se sont des images ou des 
	animations, leurs positions changent au cours du temps.
	
	10 niveau indexé par des chaînes de caractères
	1 - sous-sol
	2 - sol
	3 - sur-sol
	4 - bas-heros
	5 - taille-heros
	6 - haut-heros
	7 - sous-plafond
	8 - plafond
	9 - sur-plafond
	
	drawSprite(niveau, x, y, z, r) à partir du centre
	drawEffect(niveau, x, y, z, r) à partir du centre
	
	utilise le module camera

camera : -- core

	fonction est visible
	position : x,y
	hauteur, largeur en "metre" 
	zoom 
	rotation

	place sur l'écran

interface : --utilisateur
	
	dessine la camera et le reste

character : --utilisateur
	
	spécifie toute les actions du joueur en fonction des inputs.

spectator : --utilisateur

arenaManager : 

type : 
	monster : 
