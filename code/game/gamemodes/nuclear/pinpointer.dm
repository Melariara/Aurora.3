/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	w_class = ITEMSIZE_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	matter = list(DEFAULT_WALL_MATERIAL = 500)
	var/obj/item/disk/nuclear/the_disk = null
	var/active = 0

/obj/item/pinpointer/attack_self()
	if(!active)
		active = 1
		START_PROCESSING(SSfast_process, src)
		to_chat(usr, "<span class='notice'>You activate the pinpointer</span>")
	else
		active = 0
		STOP_PROCESSING(SSfast_process, src)
		icon_state = "pinoff"
		to_chat(usr, "<span>You deactivate the pinpointer</span>")

/obj/item/pinpointer/process()
	if (active)
		workdisk()
	else
		STOP_PROCESSING(SSfast_process, src)

/obj/item/pinpointer/proc/workdisk()
	if(!active) return
	if(!the_disk)
		the_disk = locate()
		if(!the_disk)
			icon_state = "pinonnull"
			return
	set_dir(get_dir(src,the_disk))
	switch(get_dist(src,the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"
	return TRUE

/obj/item/pinpointer/examine(mob/user)
	. = ..()
	for(var/obj/machinery/nuclearbomb/bomb in SSmachinery.machinery)
		if(bomb.timing)
			to_chat(user, "Extreme danger.  Arming signal detected.   Time remaining: [bomb.timeleft]")

/obj/item/pinpointer/Destroy()
	active = 0
	STOP_PROCESSING(SSfast_process, src)
	return ..()

/obj/item/pinpointer/advpinpointer
	name = "Advanced Pinpointer"
	icon = 'icons/obj/device.dmi'
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	var/mode = 0  // Mode 0 locates disk, mode 1 locates coordinates.
	var/turf/location = null
	var/obj/target = null

/obj/item/pinpointer/advpinpointer/attack_self()
	if(!active)
		active = 1
		if(mode == 0)
			workdisk()
		if(mode == 1)
			worklocation()
		if(mode == 2)
			workobj()
		START_PROCESSING(SSfast_process, src)
		to_chat(usr, "<span class='notice'>You activate the pinpointer</span>")
	else
		active = 0
		icon_state = "pinoff"
		cut_overlays()
		to_chat(usr, "<span class='notice'>You deactivate the pinpointer</span>")

/obj/item/pinpointer/advpinpointer/process()
	switch(mode)
		if (0)
			workdisk()
		if (1)
			worklocation()
		if (2)
			workobj()

/obj/item/pinpointer/advpinpointer/proc/worklocation()
	if(!active)
		STOP_PROCESSING(SSfast_process, src)
		return
	if(!location)
		icon_state = "pinonnull"
		return
	set_dir(get_dir(src,location))
	set_z_overlays(location)
	switch(get_dist(src,location))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"

/obj/item/pinpointer/advpinpointer/proc/set_z_overlays(var/atom/target)
	cut_overlays()
	if(AreConnectedZLevels(src.loc.z, target.z))
		if(src.loc.z > target.z)
			add_overlay("pinzdown")
		else if(src.loc.z < target.z)
			add_overlay("pinzup")
	else
		active = 0
		if(ismob(loc))
			var/mob/holder = loc
			to_chat(holder, "<span class='notice>\The [src] cannot locate chosen target, shutting down.</span>")

/obj/item/pinpointer/advpinpointer/workdisk()
	if(..())
		set_z_overlays(the_disk)

/obj/item/pinpointer/advpinpointer/proc/workobj()
	if(!active)
		STOP_PROCESSING(SSfast_process, src)
		return
	if(!target)
		icon_state = "pinonnull"
		return
	set_dir(get_dir(src,target))
	set_z_overlays(target)
	switch(get_dist(src,target))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"

/obj/item/pinpointer/advpinpointer/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in view(1)

	active = 0
	icon_state = "pinoff"
	target = null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			mode = 1

			var/locationx = tgui_input_number(usr, "Please input the x coordinate to search for.", "Pinpointer")
			if(!locationx || !(usr in view(1,src)))
				return
			var/locationy = tgui_input_number(usr, "Please input the y coordinate to search for.", "Pinpointer?")
			if(!locationy || !(usr in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(usr, "You set the pinpointer to locate [locationx],[locationy]")


			return attack_self()

		if("Disk Recovery")
			mode = 0
			return attack_self()

		if("Other Signature")
			mode = 2
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "" , "Item" , "DNA"))
				if("Item")
					var/datum/objective/steal/itemlist
					itemlist = itemlist // To supress a 'variable defined but not used' error.
					var/targetitem = tgui_input_list(usr, "Select the item to search for.", "Pinpointer", itemlist.possible_items)
					if(!targetitem)
						return
					target=locate(itemlist.possible_items[targetitem])
					if(!target)
						to_chat(usr, "Failed to locate [targetitem]!")
						return
					to_chat(usr, "You set the pinpointer to locate [targetitem]")
				if("DNA")
					var/DNAstring = tgui_input_text(usr, "Input the DNA string to search.", "Pinpointer")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/M in mob_list)
						if(!M.dna)
							continue
						if(M.dna.unique_enzymes == DNAstring)
							target = M
							break

			return attack_self()


///////////////////////
//nuke op pinpointers//
///////////////////////


/obj/item/pinpointer/nukeop
	var/mode = 0	//Mode 0 locates disk, mode 1 locates the shuttle
	var/obj/machinery/computer/shuttle_control/multi/antag/syndicate/home = null

/obj/item/pinpointer/nukeop/attack_self(mob/user as mob)
	if(!active)
		active = 1
		START_PROCESSING(SSfast_process, src)
		if(!mode)
			workdisk()
			to_chat(user, "<span class='notice'>Authentication Disk Locator active.</span>")
		else
			worklocation()
			to_chat(user, "<span class='notice'>Shuttle Locator active.</span>")
	else
		active = 0
		STOP_PROCESSING(SSfast_process, src)
		icon_state = "pinoff"
		to_chat(user, "<span class='notice'>You deactivate the pinpointer.</span>")

/obj/item/pinpointer/nukeop/process()
	if (mode)
		workdisk()
	else
		worklocation()

/obj/item/pinpointer/nukeop/workdisk()
	if(!active) return
	if(mode)		//Check in case the mode changes while operating
		worklocation()
		return
	if(bomb_set)	//If the bomb is set, lead to the shuttle
		mode = 1	//Ensures worklocation() continues to work
		worklocation()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator active.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	if(!the_disk)
		the_disk = locate()
		if(!the_disk)
			icon_state = "pinonnull"
			return
//	if(loc.z != the_disk.z)	//If you are on a different z-level from the disk
//		icon_state = "pinonnull"
//	else
	set_dir(get_dir(src, the_disk))
	switch(get_dist(src, the_disk))
		if(0)
			icon_state = "pinondirect"
		if(1 to 8)
			icon_state = "pinonclose"
		if(9 to 16)
			icon_state = "pinonmedium"
		if(16 to INFINITY)
			icon_state = "pinonfar"

/obj/item/pinpointer/nukeop/proc/worklocation()
	if(!active)	return
	if(!mode)
		workdisk()
		return
	if(!bomb_set)
		mode = 0
		workdisk()
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator active.</span>")
		return
	if(!home)
		home = locate()
		if(!home)
			icon_state = "pinonnull"
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = "pinonnull"
	else
		set_dir(get_dir(src, home))
		switch(get_dist(src, home))
			if(0)
				icon_state = "pinondirect"
			if(1 to 8)
				icon_state = "pinonclose"
			if(9 to 16)
				icon_state = "pinonmedium"
			if(16 to INFINITY)
				icon_state = "pinonfar"
