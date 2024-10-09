/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black"	//what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT
	embedding = list()

/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	colour = "black"

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
			throw_speed++
		if("red")
			colour = "green"
			throw_speed = initial(throw_speed)
		if("green")
			colour = "blue"
		else
			colour = "black"
	to_chat(user, "<span class='notice'>\The [src] will now write in [colour].</span>")
	desc = "It's a fancy four-color ink pen, set to [colour]."

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "dimgray"
	font = CHARCOAL_FONT
	custom_materials = null
	grind_results = list(/datum/reagent/ash = 5, /datum/reagent/cellulose = 10)

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	custom_materials = list(/datum/material/gold = 750)
	sharpness = IS_SHARP
	resistance_flags = FIRE_PROOF
	unique_reskin = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)
	embedding = list("embed_chance" = 75)

/obj/item/pen/fountain/captain/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 200, 115) //the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."

/obj/item/pen/attack_self(mob/living/carbon/user)
	var/deg = input(user, "What angle would you like to rotate the pen head to? (1-360)", "Rotate Pen Head") as null|num
	if(deg && (deg > 0 && deg <= 360))
		degrees = deg
		to_chat(user, "<span class='notice'>You rotate the top of the pen to [degrees] degrees.</span>")
		SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)

/obj/item/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
			if(!stealth)
				to_chat(M, "<span class='danger'>You feel a tiny prick!</span>")
			. = 1

		log_combat(user, M, "stabbed", src)

	else
		. = ..()

/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()
	//Changing Name/Description of items. Only works if they have the 'unique_rename' flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = input(user, "What would you like to edit?", "Rename or change description?") as null|anything in list("Rename","Change description")
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		if(penchoice == "Rename")
			var/input = stripped_input(user,"What do you want to name \the [O.name]?", ,"", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(oldname == input)
				to_chat(user, "<span class='notice'>You changed \the [O.name] to... well... \the [O.name].</span>")
			else
				O.name = input
				to_chat(user, "<span class='notice'>\The [oldname] has been successfully been renamed to \the [input].</span>")
				O.renamedByPlayer = TRUE

		if(penchoice == "Change description")
			var/input = stripped_input(user,"Describe \the [O.name] here", ,"", 100)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			O.desc = input
			to_chat(user, "<span class='notice'>You have successfully changed \the [O.name]'s description.</span>")

/obj/item/pen/get_writing_implement_details()
	return list(
		interaction_mode = MODE_WRITING,
		font = font,
		color = colour,
		use_bold = FALSE,
	)

/*
 * Sleepypens
 */

/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)

				reagents.trans_to(M, reagents.total_volume, transfered_by = user, method = INJECT)


/obj/item/pen/sleepy/Initialize()
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off
	sharpness = IS_SHARP
	var/on = FALSE

/obj/item/pen/edagger/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 100, 0, 'sound/weapons/blade1.ogg')
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/pen/edagger/get_sharpness()
	return on * sharpness

/obj/item/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		throw_speed = initial(throw_speed)
		w_class = initial(w_class)
		name = initial(name)
		hitsound = initial(hitsound)
		embedding = list(embed_chance = EMBED_CHANCE)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, TRUE)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
	else
		on = TRUE
		force = 18
		throw_speed = 4
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		hitsound = 'sound/weapons/blade1.ogg'
		embedding = list(embed_chance = 100) //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, TRUE)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	updateEmbedding()
	update_appearance()

/obj/item/pen/edagger/update_icon_state()
	if(on)
		icon_state = item_state = "edagger"
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
	return ..()

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe. Watchers find them very desirable for their diamond exterior."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "digging_pen"
	item_state = "pen"
	force = 3
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=10, /datum/material/diamond=100, /datum/material/titanium = 10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.

/obj/item/pen/solgov
	name = "\improper SolGov pen"
	desc = "A pen with SolGov's insignia on the side. You feel like stealing it..."
	icon_state = "pen-sg"

/obj/item/pen/terragov
	name = "\improper TerraGov pen"
	desc = "A pen with TerraGov's insignia on the side."
	icon_state = "pen-sg"

/obj/item/pen/fountain/solgov
	name = "\improper SolGov fountain pen"
	desc = "A fancy fountain pen with SolGov's insignia emblazoned onto the wood. It feels powerful. You feel like stealing it... You won't get in trouble for picking it up, will you? It is totally safe to take. The gods won't banish you permanently for this heinous crime of stealing a fancy pen, I am sure!"
	icon_state = "pen-fountain-sg"

/obj/item/pen/fountain/terragov
	name = "\improper TerraGov fountain pen"
	desc = "A fancy fountain pen with TerraGov's insignia emblazoned onto the wood."
	icon_state = "pen-fountain-sg"
/*
* collectible pens, every ship's gotta have one of em
*/
/obj/item/pen/collectible/bicblack
	name = "historic black ballpoint pen"
	desc = "A pen based off a design that popularized the usage of ballpoint pens in Terran society. This one uses black ink."
	icon_state = "pen-collectible-bicbla"

/obj/item/pen/collectible/bicblue
	name = "historic blue ballpoint pen"
	desc = "A pen based off a design that popularized the usage of ballpoint pens in Terran society. This one uses blue ink."
	icon_state = "pen-collectible-bicblu"
	colour = "blue"

/obj/item/pen/collectible/bicred
	name = "historic red ballpoint pen"
	desc = "A pen based off a design that popularized the usage of ballpoint pens in Terran society. This one uses red ink."
	icon_state = "pen-collectible-bicre"
	colour = "red"
	throw_speed = 4

/obj/item/pen/collectible/pencil
	name = "lead-based pen"
	desc = "A nonconventional pen that- Hey, this is just a pencil!"
	icon_state = "pen-collectible-pencil"
	colour = "dimgray"
	font = CHARCOAL_FONT

/obj/item/pen/collectible/mechanicalpencil
	name = "stacking point pencil"
	desc = "This is one of those mechanical pencils that you pull the point off of to get more lead. Late 20th century kids were always raving about them."
	icon_state = "pen-collectible-mpencil"
	colour = "dimgray"
	font = CHARCOAL_FONT

/obj/item/pen/collectible/sharpmarker
	name = "marker pen"
	desc = "A standard permanent marker. It's really tempting to huff its fumes."
	icon_state = "pen-collectible-sharp"
	font = CHARCOAL_FONT //i dont know if there's a marker looking font, so im using the charcoal stylus font instead, okay? okay.

/obj/item/pen/collectible/copimarker
	name = "artistic marker pen"
	desc = "An alcohol-based marker that's used by artists across the galaxies."
	icon_state = "pen-collectible-copi"
	colour = "blue"
	font = CHARCOAL_FONT

/obj/item/pen/collectible/dissasembledpen
	name = "budget-conscious pen"
	desc = "A pen stripped down to its bare essentials. Either someone lost the rest of the pieces while dissasembling it, or we're gonna have another round of layoffs soon..."
	icon_state = "pen-collectible-diss"

/obj/item/pen/collectible/cybersun
	name = "\improper Cybersun branded pen"
	desc = "A pen emblazoned with the Cybersun logo. It really makes you want to face the fear."
	icon_state = "pen-collectible-cybersun"

/obj/item/pen/collectible/calligraphybrush
	name = "\improper Cybersun calligraphy brush"
	desc = "It was said that the original founder of Cybersun's favorite hobby was calligraphy. Now, you can continue his passion with this corporate branded calligraphy brush."
	icon_state = "pen-collectible-callig"
	colour = "crimson"
	throw_speed = 4 //in case anyone asks, the red (and crimson) ink is what gives it the faster throw speed, not necessarily the color of its shell. so thats why the brush (and every red ink pen) is slightly better than the cybersun pen (or other red looking pens), i know that most of you will not care, but there's going to be that 1% that will, so im nipping this conversation in the bud right here and right now. THESE ARE THE RULES NOW, I DECLARE IT.
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/collectible/nuke
	name = "nuclear fission pen"
	desc = "A pen made to advertise the Syndicate's nuclear operative program. Leave no survivors (in your argumentative essay)!"
	icon_state = "pen-collectible-nuke"

/obj/item/pen/collectible/esword
	name = "energy pen"
	desc = "A pen cunningly disguised as an energy sword."
	icon_state = "pen-collectible-esword"
	colour = "red"
	throw_speed = 4

/obj/item/pen/collectible/syringe
	name = "writey syringe"
	desc = "A syringe that gives you the uncontrollable urge to write something down..."
	icon_state = "pen-collectible-syringe"

/obj/item/pen/collectible/terragov
	name = "\improper Terragov branded pen"
	desc = "A pen emblazoned with the Terragov flag. It fills you with Terran pride."
	icon_state = "pen-collectible-tg"

/obj/item/pen/collectible/xeno
	name = "novelty xeno pen"
	desc = "A novelty pen with the head of a rather weird looking bug at the end of it."
	icon_state = "pen-collectible-xeno"

/obj/item/pen/collectible/freedom
	name = "\improper American pen"
	desc = "A pen emblazoned with the United States flag. It fills you with the power of FREEDOM."
	icon_state = "pen-collectible-usa"

/obj/item/pen/collectible/unionjack
	name = "\improper British pen"
	desc = "A pen emblazoned with the Union Jack. It fills you with the power of the MONARCHY."
	icon_state = "pen-collectible-gb"

/obj/item/pen/collectible/nanotrasen
	name = "\improper Nanotrasen branded pen"
	desc = "A pen emblazoned with the Nanotrasen logo. It really makes you want to build the future."
	icon_state = "pen-collectible-nanotrasen"
	colour = "blue"

/obj/item/pen/collectible/plasma
	name = "plasma pen"
	desc = "A pen designed to look like a chunk of plasma."
	icon_state = "pen-collectible-plasma"
	colour = "red"
	throw_speed = 4

/obj/item/pen/collectible/bluespace
	name = "bluespace pen"
	desc = "A pen that uses a rather unscrupulous design that steals ink from other pens to fuel itself. This method of ink retrieval is so highly frowned upon, that the Pen Testers division of Terragov banned this pen in most sectors. If you're the one in possesion of this, you should probably run as fast as you can, as they are already approaching your location."
	icon_state = "pen-collectible-bluespace"
	colour = "blue"

/obj/item/pen/collectible/ntpencil
	name = "Nanotrasen Pencil"
	desc = "A proprietary pen design made by Nanotrasen for use with their documents. It has a 7500 credit retail price, and they STILL have the gall to put DRM on it..."
	icon_state = "pen-collectible-ntpencil"

/obj/item/pen/collectible/supermatterreplica
	name = "replica supermatter pen"
	desc = "Don't worry, this pen does NOT have a chunk of supermatter attached to it. It's just a replica."
	icon_state = "pen-collectible-supermatter"

/obj/item/pen/collectible/inteq
	name = "\improper Inteq branded pen"
	desc = "A pen emblazoned with the Inteq logo. It really makes you have the will to stand up straight."
	icon_state = "pen-collectible-inteq"

/obj/item/pen/collectible/bullet
	name = "bullet pen"
	desc = "A pen that looks like a bullet. Do NOT use this as ammo, you fucking idiot. Who do you think you are, examining pen descriptions and shitting in my mailbox? I need to fucking straighten you out RIGHT now, but I fucking can't because I'm just flavor text for a pen that only LOOKS like a bullet. It ISN'T actually a fucking BULLET! DO YOU UNDERSTAND YOU MORON!?"
	icon_state = "pen-collectible-bullet"

/obj/item/pen/collectible/tacticool
	name = "tacticool pen"
	desc = "A really tactical pen. You can tell because it has a serrated edge and it's painted olive drab and everything!"
	icon_state = "pen-collectible-tactical"

/obj/item/pen/collectible/corporatewar
	name = "Corporate War pen"
	desc = "A pen that is branded with the Nanotrasen, Inteq, and Syndicate logos. How disgustingly centrist."
	icon_state = "pen-collectible-corpwar"

/obj/item/pen/collectible/starlitmoon
	name = "Starlit Moon pen"
	desc = "A pen based off a painting by the late great Tiziran artist \"Gouh-Vaunz.\" It is said that he painted this piece from the view of his asylum room."
	icon_state = "pen-collectible-starry"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/collectible/quill
	name = "raptor quill pen"
	desc = "A pen made using the quill of a certain species of raptor native to Tizira."
	icon_state = "pen-collectible-quill"
	colour = "red"
	throw_speed = 4
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/collectible/moth
	name = "Men"
	desc = "Men is a moth that turned himself into a pen. You like Men, don't you?"
	icon_state = "pen-collectible-moth"

/obj/item/pen/collectible/paradiselost
	name = "Paradise Lost pen"
	desc = "A pen based off a painting of an anonymous Mothic painter. Critics still debate the meaning of this work to this day."
	icon_state = "pen-collectible-spaceplanet"

/obj/item/pen/collectible/lamp
	name = "lamp pen"
	desc = "A pen that is fashioned to look like a lamp. Moths really like it, for some reason."
	icon_state = "pen-collectible-lamp"
