$(document).ready(function() {

var defCol = "blue" // sets default colour.  Not really necessary but would be useful if adding a colour choice for the user.
var rows = 16; // Default number of squares across.
var columns = 16; // Default number of squares down.
makeGrid(rows,columns);//calls function to create the grid.
fill(defCol); // calls function to fill squares.  Passes defCol as colour to use.

// fills squares.  sqColour not necessary but gives options to change colours easily.
function fill(sqColour,colGen){
	$('.box').mouseenter(function() {
		return this.style.backgroundColor = sqColour;
	});
};

//reset button asks user for grid size.  Set to 50x50 maximum as any more runs very slowly.
$('#reset').click(function() {
	$('button').removeClass('clickedon');
	rows = prompt("How many rows?");
	columns = prompt("How many columns?");
	if(rows*columns > 2500) {
		rows = 50;
		columns = 50;
		alert("Sorry, maximum size is 50 x 50!");
	};
	makeGrid(rows,columns);
	return fill(defCol);
});
//Resets grid & turns on random colour mode. Colour generator at the bottom of the script.
$('#randcolour').click(function() {
	$(this).addClass('clickedon');
	makeGrid(rows,columns);
	$('#greyscale').removeClass('clickedon');
	$('.box').mouseenter(function() {
	return this.style.backgroundColor = colGen();		
	});
});
//Resets grid & turns on shade mode.
$('#greyscale').click(function(){
	makeGrid(rows,columns);
	$('button').removeClass('clickedon');
	$(this).addClass('clickedon');
	$('.box').css({"backgroundColor":"black","opacity":"0"});
	$('.box').mouseenter(function() {
		shade = parseFloat($(this).css("opacity"));
		if (shade < 1){
			shade += 0.1;	
		};
		return $(this).css("opacity", shade);
 	});
});

});
//Creates grid to size as chosen by user. Each square is a div with an individual id.
function makeGrid(rows, columns) {
	$('.box').remove();
	for(i=1; i <= rows*columns; i++) {
		$('<div />').addClass('box').attr('id',i).appendTo('.container');
	}
	//Sets height and width so squares always fit into container which is 500x500px
	boxWidth = 500 / columns;
	boxHeight = 500 / rows;
	$('.box').css({"height": boxHeight,"width": boxWidth});
};

//Generates random colour. 
function colGen() {
    var letters = '0123456789ABCDEF'.split(''); //splits all possible characters for hex colour into an array.
    var colour = '#';
//Math.floor(Math.random() * 16) generates a random number from 0-16.
//This number selects the character from the array and is then added to var colour.
//This repeats 6 times creating a random Hex number in var colour.
//This is then returned to colGen().
    for (var i = 0; i < 6; i++ ) {
        colour += letters[Math.floor(Math.random() * 16)];
        console.log(letters);
    }
    return colour;
};