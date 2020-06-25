cnt=0
for f in *.jpg
	do convert $f -resize 300x200  $cnt.png
	cnt=$((cnt+1))
done
