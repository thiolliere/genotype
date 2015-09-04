if [ ! "$1" ]
then
	n="5"
else
	n="$1"
fi

for i in $(seq 1 $n)
do
	love source bot > /dev/null &
	echo "created"
done
