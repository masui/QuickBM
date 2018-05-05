#
# ローカルにSinatraを走らせる
# データベースはHerokuのMongoを使う
#
local:
	MONGODB_URI=`heroku config -a quickbm | grep MONGODB_URI | ruby -n -e 'puts $$_.split[1]'` ruby quickbm.rb

clean:
	/bin/rm -f *~ */*~

push:
	git push git@github.com:masui/QuickBM.git

backup:
	cd backups; make

