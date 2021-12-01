# ./Game && exit
# rm -rf Data Unpack
# unzip -q Data.zip
ruby UnpackScripts.rb
ruby UnpackObjects.rb
ruby RepackScripts.rb
./Game
