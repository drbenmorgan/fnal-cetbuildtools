
#include <iostream>
#include "ToyCmake/DoMath.h"

int main()
{
   ToyCmake::DoMath dm(2.);
   double x = 5.;
   double y = dm.calculate(x);
   std::cout << "math on " << x << " results in " << y << std::endl;
   return 0;
}

