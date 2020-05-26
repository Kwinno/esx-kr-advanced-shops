local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX 			    			= nil
local showblip = false
local displayedBlips = {}
local AllBlips = {}
local number = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


AddEventHandler('onResourceStop', function(resource)
	  if resource == GetCurrentResourceName() then
		  SetNuiFocus(false, false)
	  end
end)
  
RegisterNUICallback('escape', function(data, cb)
	 
	  SetNuiFocus(false, false)
  
	  SendNUIMessage({
		  type = "close",
	  })
end)

RegisterNUICallback('bossactions', function(data, cb)
	 
	SetNuiFocus(false, false)

	SendNUIMessage({
		type = "close",
	})

	OpenBoss(number)
end)

local Cart = {}

RegisterNUICallback('putcart', function(data, cb)
	table.insert(Cart, {item = data.item, label = data.label, count = data.count, id = data.id, price = data.price})
	cb(Cart)
end)

RegisterNUICallback('notify', function(data, cb)
	ESX.ShowNotification(data.msg)
end)

RegisterNUICallback('refresh', function(data, cb)
	 
	Cart = {}

		ESX.TriggerServerCallback('esx_fuel_shop:getOwnedShop', function(data)
			ESX.TriggerServerCallback('esx_fuel_shop:getShopItems', function(result)
			
					if data ~= nil then
						Owner = true
					end

					if result ~= nil then

								SetNuiFocus(true, true)
				
								SendNUIMessage({
									type = "shop",
									result = result,
									owner = Owner,
								})
					end

				end, number)
			end, number)
end)

RegisterNUICallback('emptycart', function(data, cb)
	Cart = {}
	
end)

RegisterNUICallback('buy', function(data, cb)
	
		TriggerServerEvent('esx_fuel_shops:Buy', number, data.Item, data.Count)
	Cart = {}
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
   PlayerData = xPlayer
end)

local ShopId           = nil
local Msg        = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil


AddEventHandler('esx_fuel_shop:hasEnteredMarker', function(zone)
	if zone == 'center' then
		ShopId = zone
		number = zone
		Msg  = _U('press_to_open_center')
	elseif zone <= 100 then
		ShopId = zone
		number = zone
		Msg  = _U('press_to_open')
	end
end)

AddEventHandler('esx_fuel_shop:hasExitedMarker', function(zone)
	ShopId = nil
end)

Citizen.CreateThread(function ()
 	 while true do
		Citizen.Wait(0)

		if ShopId ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(Msg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

				if IsControlJustReleased(0, Keys['E']) then

					if ShopId == 'center' then
						OpenShopCenter()
					

					elseif ShopId <= 100 then
						ESX.TriggerServerCallback('esx_fuel_shop:getOwnedShop', function(data)
						ESX.TriggerServerCallback('esx_fuel_shop:getShopItems', function(result)
						
								if data ~= nil then
									Owner = true
								end
	
								if result ~= nil then

									SetNuiFocus(true, true)
						
									SendNUIMessage({
										type = "shop",
										result = result,
										owner = Owner,
									})
								end
			
							end, number)
						end, number)
					end

	 	 		end
		end
	end
 end)



function OpenShopCenter()

	ESX.UI.Menu.CloseAll()

  	local elements = {}

		if showblip then
			table.insert(elements, {label = 'Hide ALL shops on the map', value = 'removeblip'})
		else
			table.insert(elements, {label = 'Show ALL shops on the map', value = 'showblip'})
		end

			ESX.TriggerServerCallback('esx_fuel_shop:getShopList', function(data)

				for i=1, #data, 1 do
					table.insert(elements, {label = _U('buy_shop') .. data[i].ShopNumber .. ' [$' .. data[i].ShopValue .. ']', value = 'kop', price = data[i].ShopValue, shop = data[i].ShopNumber})
				end


					ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'shopcenter',
					{
						title    = 'Shop',
						align    = 'left',
						elements = elements
					},
					function(data, menu)

					if data.current.value == 'kop' then
					ESX.UI.Menu.CloseAll()

					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'name', {
					title = _U('name_shop')
					}, function(data2, menu2)

					local name = data2.value
					TriggerServerEvent('esx_fuel_shops:BuyShop', name, data.current.price, data.current.shop, data.current.bought)
					menu2.close()

					end,
					function(data2, menu2)
					menu2.close()
					end)

					elseif data.current.value == 'removeblip' then
						showblip = false
						createForSaleBlips()
						menu.close()
					elseif data.current.value == 'showblip' then
						showblip = true
						createForSaleBlips()
						menu.close()
					end
					end)
				end,
			function(data, menu)
		menu.close()
	end)
end

-- function OpenShop()
--   ESX.UI.Menu.CloseAll()
--   local elements = {}

  
-- 	ESX.TriggerServerCallback('esx_fuel_shop:getOwnedShop', function(data)
-- 	ESX.TriggerServerCallback('esx_fuel_shop:getShopItems', function(result)

--         if data ~= nil then
--             table.insert(elements, {label = 'Boss Menu', value = 'boss'})
--         end

-- 	    if result ~= nil then
-- 		    for i=1, #result, 1 do
-- 		        if result[i].count > 0 then
-- 					table.insert(elements, {label = result[i].label .. ' | ' .. result[i].count ..' in your stock for [$' .. result[i].price .. ' per item]', value = 'buy', ItemName = result[i].item})
-- 				end
-- 			end
-- 		end


--   ESX.UI.Menu.Open(
--   'default', GetCurrentResourceName(), 'shops',
--   {
-- 	title    = 'Shop',
-- 	align    = 'left',
-- 	elements = elements
--   },
--   function(data, menu)
-- 	if data.current.value == 'boss' then
--         ESX.UI.Menu.CloseAll()
-- 		OpenBoss()
		
-- 	elseif data.current.value == 'buy' then
--         	ESX.UI.Menu.CloseAll()

-- 			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'mainmeny', {
-- 			title = 'How much whould you like to buy?'
-- 			}, function(data2, menu2)

--        	 	local count = tonumber(data2.value)

-- 				TriggerServerEvent('esx_fuel_shops:Buy', number, data.current.ItemName, count)
-- 				menu2.close()
	
--                     	end,
--                     	function(data2, menu2)
--                     	menu2.close()
--                 	end)
--                     end
--                 end,
--                 function(data, menu)
-- 				menu.close()
-- 			end)
-- 		end, number)
-- 	end, number)
-- end

function OpenBoss()


  ESX.TriggerServerCallback('esx_fuel_shop:getOwnedShop', function(data)
  
	local elements = {}

		table.insert(elements, {label = 'You have: $' .. data[1].money .. ' in your company',    value = ''})
		table.insert(elements, {label = 'Shipments',    value = 'shipments'})
        table.insert(elements, {label = 'Put in a item for sale', value = 'putitem'})
        table.insert(elements, {label = 'Take out a item for sale',    value = 'takeitem'})
        table.insert(elements, {label = 'Put in money in your company',    value = 'putmoney'})
        table.insert(elements, {label = 'Take out money from your company',    value = 'takemoney'})
        table.insert(elements, {label = 'Change name on your company: $' .. Config.ChangeNamePrice,    value = 'changename'})
		table.insert(elements, {label = 'Sell your company for $' .. math.floor(data[1].ShopValue / Config.SellValue),   value = 'sell'})

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'boss',
		{
			title    = 'Shop',
			align    = 'left',
			elements = elements
		},
		function(data, menu)
        if data.current.value == 'putitem' then
            PutItem(number)
        elseif data.current.value == 'takeitem' then  
            TakeItem(number)
        elseif data.current.value == 'takemoney' then
            

            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'takeoutmoney', {
                title = 'How much whould you like to take out?'
            }, function(data2, menu2)
  
			local amount = tonumber(data2.value)
			
			TriggerServerEvent('esx_fuel_shops:takeOutMoney', amount, number)
			
			menu2.close()
        
		end,
		function(data2, menu2)
		menu2.close()
		end)

	 	elseif data.current.value == 'putmoney' then
			ESX.UI.Menu.CloseAll()

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'putinmoney', {
			title = 'How much whould you like to put in?'
			}, function(data3, menu3)
			local amount = tonumber(data3.value)
			TriggerServerEvent('esx_fuel_shops:addMoney', amount, number)
			menu3.close()
				end,
				function(data3, menu3)
			menu3.close()
		end)

		elseif data.current.value == 'sell' then
		  ESX.UI.Menu.CloseAll()    

		  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
			title = 'WRITE: (YES) without parentheses to confim'
          }, function(data4, menu4)
            
            if data4.value == 'YES' then
              TriggerServerEvent('esx_fuel_shops:SellShop', number)
              menu4.close()
			end
		    	end,
		    	function(data4, menu4)
		    menu4.close()
		end)

	  elseif data.current.value == 'changename' then
		ESX.UI.Menu.CloseAll()    

		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'changename', {
		  title = 'What whould you like to name your shop?'
        }, function(data5, menu5)
            
            TriggerServerEvent('esx_fuel_shops:changeName', number, data5.value)
            menu5.close()
               		end,
                	function(data5, menu5)
                	menu5.close()
				end)
				
			elseif data.current.value == 'shipments' then
				OpenShipments(number)

				end
        		end,
        		function(data, menu)
        	menu.close()
	    end)
    end, number)
end

function OpenShipments(id)

	local elements = {}

	table.insert(elements, {label = 'Order product', value = 'buy'})
	table.insert(elements, {label = 'Shipments', value = 'shipments'})

	ESX.UI.Menu.Open(
  	'default', GetCurrentResourceName(), 'shipments',
	{
		title    = 'Shop',
		align    = 'left',
		elements = elements
	},
	  function(data, menu)
		
		if data.current.value == 'buy' then
			ESX.UI.Menu.CloseAll()
			OpenShipmentDelivery(id)
		elseif data.current.value == 'shipments' then
			ESX.UI.Menu.CloseAll()
			GetAllShipments(id)
		end
		end,
	function(data, menu)
	menu.close()
	end)
end

function GetAllShipments(id)

	local elements = {}

	ESX.TriggerServerCallback('esx_fuel_shop:getTime', function(time)
	ESX.TriggerServerCallback('esx_fuel_shop:getAllShipments', function(items)

	local once = true
	local once2 = true

		for i=1, #items, 1 do

			if time - items[i].time >= Config.DeliveryTime and once2 then
			table.insert(elements, {label = '--READY SHIPMENTS--'})
			table.insert(elements, {label = 'Get all your shipments', value = 'pickup'})
			once2 = false
			end

			if time - items[i].time >= Config.DeliveryTime then
			table.insert(elements, {label = items[i].label,	value = items[i].item, price = items[i].price})
			end

			if time - items[i].time <= Config.DeliveryTime and once then
				table.insert(elements, {label = '--PENDING SHIPMENTS--'})
				once = false
			end

			if time - items[i].time <= Config.DeliveryTime then
				times = time - items[i].time
				table.insert(elements, {label = items[i].label .. ' time left: ' .. math.floor((Config.DeliveryTime - times) / 60) .. ' minutes' })
			end

		end

	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'allshipments',
	{
	  title    = 'Shop',
	  align    = 'left',
	  elements = elements
	},
	  function(data, menu)
		
		if data.current.value == 'pickup' then
			TriggerServerEvent('esx_fuel_shops:GetAllItems', id)
		end
	
		end,
		function(data, menu)
		menu.close()
		end)

	end, id)
	end)
end

function OpenShipmentDelivery(id)
	ESX.UI.Menu.CloseAll()
	local elements = {}

		for i=1, #Config.Items, 1 do
			table.insert(elements, {labels =  Config.Items[i].label, label =  Config.Items[i].label .. ' for $' .. Config.Items[i].price .. ' a piece ',	value = Config.Items[i].item, price = Config.Items[i].price})
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'shipitem',
			{
			title    = 'Shop',
			align    = 'left',
			elements = elements
			},
			function(data, menu)
				menu.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'krille', {
				title = 'How much do you want to buy?'
				}, function(data2, menu2)
					menu2.close()
					TriggerServerEvent('esx_fuel_shop:MakeShipment', id, data.current.value, data.current.price, tonumber(data2.value), data.current.labels)

				end, function(data2, menu2)
					menu2.close()
				end)

		end,
		function(data, menu)
		menu.close()
	end)
end


function TakeItem(number)

  local elements = {}

  ESX.TriggerServerCallback('esx_fuel_shop:getShopItems', function(result)

	for i=1, #result, 1 do
	    if result[i].count > 0 then
	    	table.insert(elements, {label = result[i].label .. ' | ' .. result[i].count ..' pieces in storage [' .. result[i].price .. ' $ per piece', value = 'removeitem', ItemName = result[i].item})
	    end
    end


  ESX.UI.Menu.Open(
  'default', GetCurrentResourceName(), 'takeitem',
  {
	title    = 'Shop',
	align    = 'left',
	elements = elements
  },
  function(data, menu)
local name = data.current.ItemName

    if data.current.value == 'removeitem' then
        menu.close()
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'howmuch', {
        title = 'How much whould you like to take out?'
        }, function(data2, menu2)

        local count = tonumber(data2.value)
		menu2.close()
    	TriggerServerEvent('esx_fuel_shops:RemoveItemFromShop', number, count, name)
    
			end, function(data2, menu2)
				menu2.close()
			end)
			end
		end,
		function(data, menu)
		menu.close()
		end)
  	end, number)
end


function PutItem(number)

  local elements = {}

  ESX.TriggerServerCallback('esx_fuel_shop:getInventory', function(result)

    for i=1, #result.items, 1 do
        
      local invitem = result.items[i]
      
	    if invitem.count > 0 then
			table.insert(elements, { label = invitem.label .. ' | ' .. invitem.count .. ' in your bag', count = invitem.count, name = invitem.name})
	    end
	end

  ESX.UI.Menu.Open(
  'default', GetCurrentResourceName(), 'putitem',
  {
	title    = 'Shop',
	align    = 'left',
	elements = elements
  },
  function(data, menu)

        local itemName = data.current.name
        local invcount = data.current.count

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell', {
			title = _U('how_much')
			}, function(data2, menu2)

			local count = tonumber(data2.value)
		
			if count > invcount then
				ESX.ShowNotification('~r~You can\'t sell more than you own')
				menu2.close()
				menu.close()
			else
				menu2.close()
				menu.close()

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sellprice', {
				title = _U('set_price')
				}, function(data3, menu3)

				local price = tonumber(data3.value)
				menu3.close()
				TriggerServerEvent('esx_fuel_shops:setToSell', number, itemName, count, price)
		
						end)
					end
				end,
				function(data3, menu3)
				menu3.close()
				end)
			end, 
			function(data2, menu2)
			menu2.close()
			end)
        end, function(data, menu)
        menu.close()
    end)
end


Citizen.CreateThread(function ()
  while true do
	Citizen.Wait(1)

	local coords = GetEntityCoords(GetPlayerPed(-1))

		for k,v in pairs(Config.Zones) do
			if(27 ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 20.0 ) then
				if v.Pos.red then
					DrawMarker(23, v.Pos.x, v.Pos.y, v.Pos.z + 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.2, 180, 0, 0, 200, false, true, 2, false, false, false, false)
					DrawMarker(29, v.Pos.x, v.Pos.y, v.Pos.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 180, 0, 0, 200, false, true, 2, false, false, false, false)		
				else
					DrawMarker(23, v.Pos.x, v.Pos.y, v.Pos.z + 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.2, 0, 180, 0, 200, false, true, 2, false, false, false, false)
					DrawMarker(29, v.Pos.x, v.Pos.y, v.Pos.z + 1.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 180, 0, 200, false, true, 2, false, false, false, false)
				end
	        end
	    end
    end
end)


Citizen.CreateThread(function ()
  while true do
	Citizen.Wait(25)

	local coords      = GetEntityCoords(GetPlayerPed(-1))
	local isInMarker  = false
	local currentZone = nil

	for k,v in pairs(Config.Zones) do
	  if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 1.2) then
		isInMarker  = true
		currentZone = v.Pos.number
	  end
	end

	if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
	  HasAlreadyEnteredMarker = true
	  LastZone                = currentZone
	  TriggerEvent('esx_fuel_shop:hasEnteredMarker', currentZone)
	end

	if not isInMarker and HasAlreadyEnteredMarker then
	  HasAlreadyEnteredMarker = false
	  TriggerEvent('esx_fuel_shop:hasExitedMarker', LastZone)
	end
  end
end)

RegisterNetEvent('esx_fuel_shops:setBlip')
AddEventHandler('esx_fuel_shops:setBlip', function()

  	ESX.TriggerServerCallback('esx_fuel_shop:getOwnedBlips', function(blips)

		if blips ~= nil then
			createBlip(blips)
	  	end
   	end)
end)

RegisterNetEvent('esx_fuel_shops:removeBlip')
AddEventHandler('esx_fuel_shops:removeBlip', function()

	for i=1, #displayedBlips do
    	RemoveBlip(displayedBlips[i])
	end

end)

AddEventHandler('playerSpawned', function(spawn)
	Citizen.Wait(500)

	ESX.TriggerServerCallback('esx_fuel_shop:getOwnedBlips', function(blips)

		if blips ~= nil then
			createBlip(blips)
		end
	end)
end)



Citizen.CreateThread(function()
	Citizen.Wait(500)

	ESX.TriggerServerCallback('esx_fuel_shop:getOwnedBlips', function(blips)

		if blips ~= nil then
			createBlip(blips)
		end
	end)
end)

Citizen.CreateThread(function()
	Citizen.Wait(500)
		local blip = AddBlipForCoord(6.09, -708.89, 44.97)

		SetBlipSprite (blip, 605)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.2)
		SetBlipColour (blip, 5)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Properties')
		EndTextCommandSetBlipName(blip)
end)

function createBlip(blips)
	for i=1, #blips, 1 do
  		for k,v in pairs(Config.Zones) do
			if v.Pos.number == blips[i].ShopNumber then
				local blip = AddBlipForCoord(vector3(v.Pos.x, v.Pos.y, v.Pos.z))
					SetBlipSprite (blip, 361)
					SetBlipDisplay(blip, 4)
					SetBlipScale  (blip, 1.2)
					SetBlipColour (blip, 29)
					SetBlipAsShortRange(blip, true)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(blips[i].ShopName)
                    EndTextCommandSetBlipName(blip)
					table.insert(displayedBlips, blip)
			end
 		end
	end
end


function createForSaleBlips()
	if showblip then

		IDBLIPS = {
			[1] = {x = 49.4187, y = 2778.793, z = 58.043, n = 1},
			[2] = {x = 263.894, y = 2606.463, z = 44.983, n = 2},
			[3] = {x = 1039.958, y = 2671.134, z = 39.550, n = 3},
			[4] = {x = 1207.260, y = 2660.175, z = 37.899, n = 4},
			[5] = {x = 2539.685, y = 2594.192, z = 37.944, n = 5},
			[6] = {x = 2679.858, y = 3263.946, z = 55.240, n = 6},
			[7] = {x = 2005.055, y = 3773.887, z = 32.403, n = 7},
			[8] = {x = 1687.156, y = 4929.392, z = 42.078, n = 8},
			[9] = {x = 1701.314, y = 6416.028, z = 32.763, n = 9},
			[10] = {x = 179.857, y = 6602.839, z = 31.868, n = 10},
			[11] = {x = -94.4619, y = 6419.594, z = 31.489, n = 11},
			[12] = {x = -2554.996, y = 2334.40, z = 33.078, n = 12},
			[13] = {x = -1800.375, y = 803.661, z = 138.651, n = 13},
			[14] = {x = -1437.622, y = -276.747, z = 46.207, n = 14},
			[15] = {x = -2096.243, y = -320.286, z = 13.168, n = 15},
			[16] = {x = -724.619, y = -935.1631, z = 19.213, n = 16},
			[17] = {x = -526.019, y = -1211.003, z = 18.184, n = 17},
			[18] = {x = -70.2148, y = -1761.792, z = 29.534, n = 18},
			[19] = {x = 265.648, y = -1261.309, z = 29.292, n = 19},
			[20] = {x = 819.653, y = -1028.846, z = 26.403, n = 20},
			[21] = {x = 1208.951, y = -1402.567, z = 35.224, n = 21},
			[22] = {x = 1181.381, y = -330.847, z = 69.316, n = 22},
			[23] = {x = 620.843, y = 269.100, z = 103.089, n = 23},
			[24] = {x = 2581.321, y = 362.039, z = 108.468, n = 24},
			[25] = {x = 176.631, y = -1562.025, z = 29.263, n = 25},
			[26] = {x = 176.631, y = -1562.025, z = 29.263, n = 26},
			[27] = {x = -319.292, y = -1471.715, z = 30.549, n = 27},
			[28] = {x = 1784.324, y = 3330.55, z = 41.253, n = 28},
		}

		for i=1, #IDBLIPS, 1 do

			local blip2 = AddBlipForCoord(vector3(IDBLIPS[i].x, IDBLIPS[i].y, IDBLIPS[i].z))
				
				SetBlipSprite (blip2, 361)
				SetBlipDisplay(blip2, 4)
				SetBlipScale  (blip2, 0.8)
				SetBlipColour (blip2, 1)
				SetBlipAsShortRange(blip2, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString('ID: ' .. IDBLIPS[i].n)
				EndTextCommandSetBlipName(blip2)
				table.insert(AllBlips, blip2)
		end

		else
			for i=1, #AllBlips, 1 do
				RemoveBlip(AllBlips[i])
			end
		ESX.UI.Menu.CloseAll()
	end
end
