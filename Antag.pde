//TODO: Less hardcoding
class Antag extends Object{
  color c;
  
  Antag(PVector _pos, float _dir) {
    super(_pos, new PVector(), _dir, 12);
    c=color(0, 255, 0);
  }
}
