project=$(tools/readtable.lua project.lua project.name)

echo Deleting $project.love...
rm $project.love
cd src
zip -r ../$project.love *
cd ..
adb push $project.love /sdcard/$project.love
adb shell am start -S -n "org.love2d.android/.GameActivity" -d "file:///sdcard/$project.love"
