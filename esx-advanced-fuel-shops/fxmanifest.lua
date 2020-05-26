-- Resource Metadata
fx_version 'bodacious'
games { 'gta5' }

author 'Kwinno, KRILLE'
description 'Fuel shop system'
version '0.0.1'

ui_page('html/index.html') 

files({
  'html/index.html',
  'html/script.js',
  'html/style.css',
	'html/img/fuel.png',
  'html/font/vibes.ttf',
  'html/img/box.png',
	'html/img/carticon.png',
})

client_scripts {
  'config.lua',
  'client/main.lua',
  '@es_extended/locale.lua',
  'locales/en.lua',
  'locales/fr.lua',	
  'locales/sv.lua',
}

server_scripts {
  'config.lua',
  'server/main.lua',
  '@mysql-async/lib/MySQL.lua'
}
