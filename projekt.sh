#!/bin/bash
# Author           : Jakub Lewkowicz ( email )
# Created On       : 08-05-2018
# Last Modified By : Jakub Lewkowicz ( email )
# Last Modified On : 08-05-2018 
# Version          : 1.0
#
# Description      :
# Skryptu korzystający z ffmpeg, ffprobe, imagemagick do tworzenia gifów i wycinania klatek z plików wideo.
# interfejs graficzny wykonany przy pomocy zenity. Skrypt został napisany w celu zaliczenia projektu z Systemów Operacyjnych
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)




case $1 in
	"--help") echo "Witam w projekcie na przedmiot Systemy Operacyjne
	dostępne parametry wywołania:
	-h szybka pomoc
	-v informacje o obecnej wersji
	aby skrypt dzialal poprawnie wymagane jest zainstalowanie programow ffmpeg, ffprobe oraz imagemagick" && exit;;
	"-v") echo "Projekt SO 171646 version 1.0" && exit;;
	"-h") echo "-h szybka pomoc	-v informacje o obecnej wersji" && exit;;
esac


zenity --question --text="Wybierz tryb pracy programu. Dostepne są dwie możliwosci. Tworzenie GIFa z pliku wideo lub wycięcie rządanej klatki i poddanie jej obróbce." --title="Projekt SO 171646" --ok-label="tworzenie GIFa" --cancel-label="wyciecie klatki" --width=400 2>/dev/null

case $? in
	0) CHOICE="gif";;
	1) CHOICE="klatka";;
esac

zenity --notification --window-icon="info" --text="Wybierz plik, a nastepnie zatwierdź swój wybór. Przycisk Cancel kończy prace programu."
FILE=$(zenity --file-selection --title="Projekt SO 171646" 2>/dev/null) 
if [ $? = 1 ]; then exit
fi


case $CHOICE in
	#tworzenia gifa
	"gif")
	FRAME=$(zenity --scale --text="wybierz ilość klatek na sekunde dla tworzonego GIFa" --title="Projekt SO 171646" --min-value=1 --max-value=20 --value=5 --step=1 2>/dev/null)
	if [ $? = 1 ]; then exit
	fi
	VALIDATION=false

	until [ $VALIDATION == true ]; do
		zenity --info --title="Projekt SO 171646" --text="Za chwilę kolejno ukażą się 3 okna (godziny, minuty, sekundy). Podaj moment, od którego chcesz zacząć tworzenie GIFa, jesli chcesz aby GIF był stworzony od początku pliku ustaw wszystkie wartości na 0" --width=400 2>/dev/null
		HOURS=$(zenity --scale --text="Okno 1 z 3. Podaj godzinę " --title="Projekt SO 171646" --min-value=0 --max-value=5 --value=0 --step=1 2>/dev/null)
		if [ $? = 1 ]; then exit
		fi
		MINUTES=$(zenity --scale --text="Okno 2 z 3. Podaj minutę " --title="Projekt SO 171646" --min-value=0 --max-value=59 --value=0 --step=1 2>/dev/null)
		if [ $? = 1 ]; then exit
		fi
		SECONDS=$(zenity --scale --text="Okno 3 z 3. Podaj sekundę " --title="Projekt SO 171646" --min-value=0 --max-value=59 --value=0 --step=1 2>/dev/null)
		if [ $? = 1 ]; then exit
		fi
		REALTIME=$( ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $FILE)
		REALTIME=$(echo $REALTIME | cut -d "." -f 1)
		HOURS=$(expr $HOURS \* 3600)
		MINUTES=$(expr $MINUTES \* 60)
		TIME=$( expr $HOURS + $MINUTES + $SECONDS)
	
		if [ $TIME -gt $REALTIME ]; then VALIDATION=false zenity --warning --text="podaj poprawny czas rozpoczecia GIFa. Twój czas był większy niż długość pliku wideo ..." --width=400 2>/dev/null
		else VALIDATION=true 
		fi
	
	done


	DATA=$(zenity --forms --text="Podaj szerokosc, a wysokość zostanie ustalona automatycznie zachowująć proporcje rozdzielczości pliku wejściowego" --title="Projekt SO 171646" --add-entry="nazwa pliku wyjsciowego" --add-entry="szerokość GIFa w pikselach" 2>/dev/null)
	if [ $? = 1 ]; then exit
	fi

	DURATION=$(zenity --scale --title="Projekt SO 171646" --text="Wybierz czas trwania GIFa" --min-value=5 --max-value=60 --value=10 --step=1 2>/dev/null)
	if [ $? = 1 ]; then exit
	fi

	FILENAME=$(echo $DATA | cut -d "|" -f 1)
	WIDTH=$(echo $DATA | cut -d "|" -f 2)

	zenity --question --title="Projekt SO 171646" --text="Czy chcesz utworzyć GIFa?" --ok-label="tak" --cancel-label="nie" 2>/dev/null
	if [ $? = 1 ]; then exit
	else
	ffmpeg -v warning -ss $TIME -t $DURATION -i $FILE -r $FRAME -vf scale=$WIDTH:-1 -gifflags -transdiff -y ${FILENAME}.gif
	fi;;
	
	"klatka") 
	
	#wycinanie klatek i dodawanie napisow
	TYPE=$(zenity --list --radiolist --text="wybierz format pliku wyjsciowego" --title="Projekt SO 171646" --column="Wybierz" --column="format" TRUE "jpg" FALSE "png" 2>/dev/null)
	if [ $? = 1 ]; then exit
	fi
		VALIDATION=false

	until [ $VALIDATION == true ]; do
		zenity --info --title="Projekt SO 171646" --text="Za chwilę kolejno ukażą się 3 okna (godziny, minuty, sekundy). Podaj czas, dla którego chcesz wyciąć klatkę z pliku wideo." --width=400 2>/dev/null
		HOURS=$(zenity --scale --text="Okno 1 z 3. Podaj godzinę " --title="Projekt SO 171646" --min-value=0 --max-value=5 --value=0 --step=1 2>/dev/null)
		if [ $? = 1 ]; then exit
		fi
		MINUTES=$(zenity --scale --text="Okno 2 z 3. Podaj minutę " --title="Projekt SO 171646" --min-value=0 --max-value=59 --value=0 --step=1 2>/dev/null)
		if [ $? = 1 ]; then exit
		fi
		SECONDS=$(zenity --scale --text="Okno 3 z 3. Podaj sekundę " --title="Projekt SO 171646" --min-value=0 --max-value=59 --value=0 --step=1 2>/dev/null)
		if [ $? = 1 ]; then exit
		fi
		REALTIME=$( ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $FILE)
		REALTIME=$(echo $REALTIME | cut -d "." -f 1)
		HOURS=$(expr $HOURS \* 3600)
		MINUTES=$(expr $MINUTES \* 60)
		TIME=$( expr $HOURS + $MINUTES + $SECONDS)
	
		if [ $TIME -gt $REALTIME ]; then VALIDATION=false zenity --warning --text="podaj poprawny czas dla rządanej klatki. Twój czas był większy niż długość pliku wideo ..." --width=400 2>/dev/null
		else VALIDATION=true 
		fi
	
	done
	
	DATA=$(zenity --forms --title="Projekt SO 171646" --add-entry="nazwa pliku wyjsciowego" --add-entry="szerokość obrazka w pikselach" --add-entry="wysokość obrazka w pikselach" 2>/dev/null)
	if [ $? = 1 ]; then exit
	fi
	
	FILENAME=$(echo $DATA | cut -d "|" -f 1)
	WIDTH=$(echo $DATA | cut -d "|" -f 2)
	HEIGHT=$(echo $DATA | cut -d "|" -f 3)
	
	zenity --question --title="Projekt SO 171646" --text="Czy wyciąć klatkę?" --ok-label="tak" --cancel-label="nie" 2>/dev/null
	if [ $? = 1 ]; then exit
	else
		ffmpeg -ss $TIME -i $FILE -s ${WIDTH}x${HEIGHT} -vframes 1 ${FILENAME}.${TYPE}
		zenity --question --title="Projekt SO 171646" --text="Czy chcesz dodać tekst do obrazka" --ok-label="tak" --cancel-label="nie" 2>/dev/null
		if [ $? = 1 ]; then exit
		else
		TEXT=$(zenity --entry --title="Projekt SO 171646" --text="podaj tresc, ktora chcesz umiescic na obrazku" 2>/dev/null)
		
		COLOR=$(zenity --list --radiolist --text="wybierz pozycje tekstu" --title="Projekt SO 171646" --column="Wybierz" --column="pozycje" TRUE "Zółty" FALSE "Zielony" FALSE "Czerwony" FALSE "Niebieski" FALSE "Czarny" FALSE "Biały" --height 400 2>/dev/null)
		case $COLOR in
			"Zółty") COLOR="yellow";;
			"Zielony") COLOR="green";;
			"Czerwony") COLOR="red";;
			"Niebieski") COLOR="blue";;
			"Czarny") COLOR="black";;
			"Biały") COLOR="white";;
		esac
		
		POSITION=$(zenity --list --radiolist --text="wybierz pozycje tekstu" --title="Projekt SO 171646" --column="Wybierz" --column="pozycje" TRUE "środek" FALSE "góra" FALSE "dół" FALSE "prawo" FALSE "lewo" --height=400 2>/dev/null)
		case $POSITION in
			"środek") POSITION="Center";;
			"góra") POSITION="North";;
			"dół") POSITION="South";;
			"prawo") POSITION="East";;
			"lewo") POSITION="West";;
		esac
		
		SIZE=$(zenity --scale --text="prosze podać rozmiar czcionki" --title="Projekt SO 171646" --min-value=0 --max-value=200 --value=40 --step=1 2>/dev/null)
		
		FONT=$(zenity --list --radiolist --text="wybierz czcionke tekstu" --title="Projekt SO 171646" --column="Wybierz" --column="czcionke" TRUE "Helvetica-Bold" FALSE "Courier-Bold" FALSE "Arial-Narrow" FALSE "Times-Roman" --height=400 2>/dev/null)
		
		convert ${FILENAME}.${TYPE} -gravity $POSITION -font $FONT -pointsize $SIZE -fill $COLOR  -annotate 0 "$TEXT" ${FILENAME}.${TYPE}
		fi
	fi;;
	
esac










