#include <stdio.h>

//Uses Variables to construct a sentence
int main()
{
    int HighGrade = 91, MedGrade = 80, LowGrade = 70;

    //Sentence for High Grade
    printf( "For this class, the grade I want is a %d. \nWhen the class gets more difficult I will sometimes settle for a %d.\nMy goal is to not drop my grade below a %d.\n", HighGrade, MedGrade, LowGrade);

    return 0;
}