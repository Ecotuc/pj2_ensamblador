////////////////////////////////////////////////////////////////////////////////////
/////////////////////////CIENCIAS DE LA COMPUTACON III - 2017///////////////////////
////////////////////////////////UNIVERSIDAD GALILEO/////////////////////////////////
///////////////////////////////Proyecto-2 Ensamblador///////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

.data
ADD_: .asciz "ADD"
READ_MODE: .asciz "r"
WORD: .space 100
CHAR: .asciz "%c\n"
HOPE: .asciz "TENGO LA ESPERANZA DE QUE AQUI SALGA LO QUE ESPERO %s\n"
TO_CODE_MESSAGE: .asciz "Instrucciones a Codificar:\n..........................\n%s"
CODED_MESSAGE:	.asciz "\nInstrucciones Codificadas:\n.........................."
INSTRUCCION_: .asciz "0x%08x\n"
args_error_msg: .asciz "No se Ingreso el Numero Correcto de Parametros"
dot_data: .space 1000 	//el area de data
dot_text: .space 4000	//el area de texto
file_buffer: .space 8000//el buffer que guardara el texto a codificar
.text
  .globl main


////////////////////////////////////////////////////////////////////////////
//////////////////////////START READ FILE///////////////////////////////////
///////ESTA SECCION NO SE DEBE CAMBIAR, PERO ES BUENO QUE LA ENTIENDAN//////
//////////////X0: el buffer donde guardaremos los caracteres////////////////
////////////////////X1: el archivo que vamos a abrir////////////////////////
////////////////////////////////////////////////////////////////////////////
read_file: 		//x0 es el buffer, x1 es el archivo
   ADD SP, SP, #-32
   STR x30,[SP,#0]
   STR x19,[SP,#8]
   STR x20,[SP,#16]
   STR x21,[SP,#24]
   MOV x19, x0		//el buffer
   MOV x20, x1		//el archivo
read_file_loop:
   MOV x0, x20
   BL fgetc
   MOV x21,x0
   MOV x0,x20
   BL feof
   CMP x0,#0
   B.NE read_file_finish
   STR x21,[x19,#0]
   ADD x19,x19, #1
   B read_file_loop
read_file_finish:
   MOV x9,#0		//un \0 diciendo que se acabo el archivo
   STR x9,[x19,#0]
   LDR x21,[SP,#24]
   LDR x20,[SP,#16]
   LDR x19,[SP,#8]
   LDR x30,[SP,#0]
   ADD SP, SP, #32
   RET
/////////////////////////////////////////////////////////////////////////////
///////////////////////////END READ FILE/////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////
////////////////////////////DISPLAY INSTRUCTIONS/////////////////////////////
////////NO DEBEN CAMBIAR ESTA SECCION, PERO ES BUENO QUE LA ENTIENDAN////////
//////////////////x0: dot_text, para desplegar las instrucciones/////////////
/////////////////////////////////////////////////////////////////////////////
display_instructions:
   ADD SP, SP, #-16
   STR x30,[SP,#0]
   STR x19,[SP,#8]
   MOV x19, x0
   LDR x0,=CODED_MESSAGE
   BL puts
display_loop:
   LDR x0,=INSTRUCCION_
   LDR w1,[x19,#0]
   ADD x19,x19,#4 	//DE 4 EN 4 PARA CADA INSTRUCCION
   CMP w1,#0
   B.EQ finish_display
   BL printf
   B display_loop
finish_display:
   LDR x19,[SP,#8]
   LDR x30,[SP,#0]
   ADD SP, SP, #16
   RET
//////////////////////////////////////////////////////////////////////////////
/////////////////////////END DISPLAY INSTRUCTIONS/////////////////////////////
//////////////////////////////////////////////////////////////////////////////





//////////////////////////////////////////////////////////////////////////////
///////////////////////////////encode/////////////////////////////////////////
/////////////////////x0: buffer con las instrucciones/////////////////////////
/////////////////////////////x1: area de texto////////////////////////////////
/////////////////////////////x2: area de data ////////////////////////////////
///////////////////ESTA ES LA FUNCION QUE DEBEN IMPLEMENTAR///////////////////
//////////////////////////////////////////////////////////////////////////////



/////x0 = BUFFER DE INSTRUCCIONES
/////x1 = ESPACIO PARA GUARDAR UNA PALABRA
get_word:
   SUB SP, SP, #32
   STR x30, [SP,#0]
   STR x19, [SP,#8]
   STR x20, [SP,#16]
   MOV x19,x0		//GUARDO EN x19 EL BUFFER DE INSTRUCCIONES
   MOV x20,x1		//GUARDO EN x20 EL ESPACIO PARA LA PALABRA
ignore_char:
   LDRB w9,[x0,#0]
   CMP w9,' '   //COMPARANDO CON ESPACIO
   B.EQ ignore_char_loop
   CMP w9,#9 	//COMPARANDO CON TAB
   B.EQ ignore_char_loop
   CMP w9,'\n'	//COMPARANDO CON \n
   B.EQ ignore_char_loop
   CMP w9,','	//COMPARANDO CON COMA
   B.EQ ignore_char_loop
   CMP w9,#0	//COMPARANDO CON NULL
   B.EQ finish_get_word
   B get_word_loop
ignore_char_loop:
   ADD x0, x0, #1
   B ignore_char

get_word_loop:
   LDRB w9,[x0,#0]
   CMP w9,' '
   B.EQ finish_get_word
   CMP w9,','
   B.EQ finish_get_word
   CMP w9,'\n'
   B.EQ finish_get_word
   CMP w9,#0
   B.EQ finish_get_word
   STRB w9,[x1,#0]
   ADD x1, x1, #1
   ADD x0, x0, #1
   B get_word_loop
finish_get_word:
   MOV w10,#0
   STRB w10,[x1,#0]
   LDR x30, [SP,#0]
   LDR x19, [SP,#8]
   LDR x20,[SP,#16]
   ADD SP, SP, #32
   RET


add_case:
   MOV w0,#0x8B0
   LSL w0, w0, #20
   B code_r_instruction

encode:
   SUB SP, SP, #48
   STR x19,[SP,#0]
   STR x20,[SP,#8]
   STR x21,[SP,#16]
   STR x22,[SP,#24]
   STR x30,[SP,#32]
   MOV x19,x0		//BUFFER
   MOV x20,x1		//AREA DE TEXTO
   MOV x21,x2

   MOV x0,x19		//PARAMETRO 1 (BUFFER)
   LDR x1,=WORD		//PARAMETRO 2 (ESPACIO DONDE GUARADARE LA PALABRA)
   BL get_word
   MOV x19,x0		//DESECHANDO LO QUE YA LEI DEL BUFFER
   LDR x0,=WORD
   LDR x1,=ADD_
   BL strcmp
   CMP x0,#0
   B.EQ add_case
   B finish_encode
code_r_instruction:
   MOV w22,w0

   MOV x0, x19
   LDR x1,=WORD
   BL get_word
   MOV x19,x0
   LDR x0,=WORD
   ADD x0,x0, #1
   BL atoi
   ORR w22, w22, w0

   MOV x0,x19
   LDR x1,=WORD
   BL get_word
   MOV x19, x0
   LDR x0,=WORD
   ADD x0,x0,#1
   BL atoi
   LSL w0, w0, #5
   ORR w22, w22, w0

   MOV x0,x19
   LDR x1,=WORD
   BL get_word
   MOV x19,x0
   LDR x0,=WORD
   ADD x0,x0,#1
   BL atoi
   LSL w0,w0,#16
   ORR w22, w22, w0
   
   STR w22, [x20,#0]
   ADD x20, x20, #4
   
finish_encode:
   LDR x19,[SP,#0x0]
   LDR x20,[SP,#0x8]
   LDR x21,[SP,#0x10]
   LDR x22,[SP,#0x18]
   LDR x30,[SP,#0x20]
   ADD SP, SP,#48
   RET
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////FINISH ENCODE///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////MAIN////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
main:
   ADD SP, SP, #-16
   STR x30,[SP,#0]
   CMP x0, #2
   BNE args_error
   MOV x27, x1		//argv se guarda en x27
   LDR x19,=file_buffer	//x19 guarda el buffer de caracteres ya leidos
   LDR x20,=dot_text	//x20 guarda el area de texto
   LDR x21,=dot_data	//x21 guarda el area de data
   LDR x0,[x27,#8]
   LDR x1,=READ_MODE
   BL fopen
   MOV x22, x0		//el archivo del que leeremos esta en x22
   MOV x0, x19
   MOV x1, x22
   BL read_file		//leemos el archivo completo
   MOV x0, x22
   BL fclose
   LDR x0,=TO_CODE_MESSAGE
   MOV x1,x19
   BL printf		//vamos a imprimir que hay en el buffer
   MOV x0, x19		//x0 tendra el buffer
   MOV x1, x20		//x1 tendra el area de texto
   MOV x2, x21		//x2 tendra el area de data
   BL encode		//esta es la ultima instruccion que hay que codificar
   MOV x0, x20    	//desplegaremos las instrucciones codificadas
   BL display_instructions
main_finish:
   MOV x0,#0 		// return 0 :)
   LDR x30,[SP,#0]
   ADD SP, SP, #16
   RET
args_error:
   LDR x0,=args_error_msg
   BL puts
   B main_finish

