#include <iostream>
#include <random>
#include <ctime>

using namespace std;

int main() {
    // Seed random number generator
    mt19937 rng(time(nullptr));
    
    // Generate random test case
    // Example: generate two integers for a simple addition problem
    uniform_int_distribution<int> dist(1, 1000);
    
    int a = dist(rng);
    int b = dist(rng);
    
    cout << a << " " << b << endl;
    
    return 0;
}