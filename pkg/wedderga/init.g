#############################################################################
##
#W  init.g                The Wedderga package            Osnel Broche Cristo
#W                                                        Alexander Konovalov
#W                                                            Aurora Olivieri
#W                                                           Gabriela Olteanu
#W                                                              �ngel del R�o
##
#H  $Id: init.g,v 1.11 2008/01/03 14:43:22 alexk Exp $
##
#############################################################################

# read Wedderga declarations
ReadPackage( "wedderga/lib/wedderga.gd" );
ReadPackage( "wedderga/lib/crossed.gd" );

# read the other part of code
ReadPackage("wedderga/lib/wedderga.g");

# set the default InfoLevel
SetInfoLevel( InfoWedderga, 1 );