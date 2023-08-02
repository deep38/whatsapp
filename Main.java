interface A {
    void print();
}

interface B {
    public void print();
}

abstract class C implements A, B {
    // @Override
    // public void print() {
    //     System.out.println("C");
    // }
}

class D extends C {
    @Override
    public void print() {
        System.out.println("IN d");
    }
}

class Main { 
    public static void main(String[] args) {
        System.out.println("Hello wrold");

        D c = new D();
        c.print();
    }
}