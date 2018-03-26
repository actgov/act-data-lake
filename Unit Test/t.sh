echo "hi there"
echo

NameVar=$"Giraffe"

G=$(maprcli volume info -name Volume$NameVar -json | grep "Volume"$NameVar)
echo $G

./u.sh 

echo
echo "Script completed."

