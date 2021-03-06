/client/proc/edit_admin_permissions()
	set category = "Admin"
	set name = "Permissions Panel"
	set desc = "Edit admin permissions"
	if(!check_rights(R_SENIORADMIN))
		return
	usr.client.holder.edit_admin_permissions()

/datum/admins/proc/edit_admin_permissions()
	if(!check_rights(R_SENIORADMIN))
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Permissions Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:125px;text-align:right;'>CKEY <a class='small' href='?src=\ref[src];editrights=add'>\[+\]</a></th>
<th style='width:125px;'>RANK</th>
<th style='width:375px;'>PERMISSIONS</th>
<th style='width:100%;'>VERB-OVERRIDES</th>
</tr>
"}

	for(var/adm_ckey in admin_datums)
		var/datum/admins/D = admin_datums[adm_ckey]
		if(!D)
			continue

		var/rights = rights2text(D.rank.rights," ")
		if(!rights)	rights = "*none*"

		output += "<tr>"
		output += "<td style='text-align:right;'>[adm_ckey] <a class='small' href='?src=\ref[src];editrights=remove;ckey=[adm_ckey]'>\[-\]</a></td>"
		output += "<td><a href='?src=\ref[src];editrights=rank;ckey=[adm_ckey]'>[D.rank.name]</a></td>"
		output += "<td><a class='small' href='?src=\ref[src];editrights=permissions;ckey=[adm_ckey]'>[rights]</a></td>"
		output += "<td><a class='small' href='?src=\ref[src];editrights=permissions;ckey=[adm_ckey]'>[rights2text(0," ",D.rank.adds,D.rank.subs)]</a></td>"
		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=editrights;size=900x650")

/datum/admins/proc/log_admin_rank_modification(adm_ckey, new_rank)
	if(config.admin_legacy_system)
		return

	if(!usr.client)
		return

	if (!check_rights(R_SENIORADMIN))
		return

	establish_db_connection()

	if(!dbcon.IsConnected())
		usr.text2tab("<span class='danger'>Failed to establish database connection.</span>","asay")
		return

	if(!adm_ckey || !new_rank)
		return

	adm_ckey = ckey(adm_ckey)

	if(!adm_ckey)
		return

	if(!istext(adm_ckey) || !istext(new_rank))
		return

	var/DBQuery/select_query = dbcon.NewQuery("SELECT id FROM [format_table_name("admin")] WHERE ckey = '[adm_ckey]'")
	select_query.Execute()

	var/new_admin = 1
	var/admin_id
	while(select_query.NextRow())
		new_admin = 0
		admin_id = text2num(select_query.item[1])

	if(new_admin)
		var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO [format_table_name("admin")] (ckey, rank, flags) VALUES ('[adm_ckey]', '[new_rank]', 0)")
		insert_query.Execute()
		usr.text2tab("<span class='adminnotice'>New admin added.</span>")
	else
		if(!isnull(admin_id) && isnum(admin_id))
			var/DBQuery/insert_query = dbcon.NewQuery("UPDATE [format_table_name("admin")] SET rank = '[new_rank]' WHERE id = [admin_id]")
			insert_query.Execute()
			usr.text2tab("<span class='adminnnotice'>Admin rank changed.</span>")


/datum/admins/proc/log_admin_permission_modification(adm_ckey, new_permission)
	if(config.admin_legacy_system)
		return
	if(!usr.client)
		return
	if(check_rights(R_SENIORADMIN))
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr.text2tab("<span class='danger'>Failed to establish database connection.</span>","asay")
		return

	if(!adm_ckey || !istext(adm_ckey) || !isnum(new_permission))
		return

	var/DBQuery/select_query = dbcon.NewQuery("SELECT id, flags FROM [format_table_name("admin")] WHERE ckey = '[adm_ckey]'")
	select_query.Execute()

	var/admin_id
	while(select_query.NextRow())
		admin_id = text2num(select_query.item[1])

	if(!admin_id)
		return

	var/DBQuery/insert_query = dbcon.NewQuery("UPDATE `[format_table_name("admin")]` SET flags = [new_permission] WHERE id = [admin_id]")
	insert_query.Execute()
