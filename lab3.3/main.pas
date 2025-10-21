unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls, Vcl.Menus;

type
  TGLVec3 = array[0..2] of GLfloat;
  PGLVec3 = ^TGLVec3;

type
  TFMain = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure DrawColoredVertex(const Coord: PGLfloat; const Color: PGLfloat);
    procedure Draw3D;
  private
    { Private declarations }
    Angle:real;
    hrc:HGLRC;
    DC:HDC;
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

procedure SetDCPixelFormat (hdc : HDC);
var pfd:TPixelFormatDescriptor; nPixelFormat:Integer;
begin
  FillChar (pfd, SizeOf (pfd), 0);
  pfd.dwFlags:=PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  nPixelFormat :=ChoosePixelFormat (hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd)
end;

procedure TFMain.DrawColoredVertex(const Coord: PGLfloat; const Color: PGLfloat);
begin
  glColor3fv(Color);
  glVertex3fv(Coord);
end;

procedure TFMain.Draw3D;
const h=1.0;
const Acoord: TGLVec3  = ( h,  h,  h); // A
const Bcoord: TGLVec3  = (-h,  h,  h); // B
const Ccoord: TGLVec3  = (-h, -h,  h); // C
const Dcoord: TGLVec3  = ( h, -h,  h); // D
const A1coord: TGLVec3 = ( h,  h, -h); // A1
const B1coord: TGLVec3 = (-h,  h, -h); // B1
const C1coord: TGLVec3 = (-h, -h, -h); // C1
const D1coord: TGLVec3 = ( h, -h, -h); // D1
var c1,c2,c3:real;
var Acolor, Bcolor, Ccolor, Dcolor: TGLVec3;
var A1color, B1color, C1color, D1color: TGLVec3;
begin
  c1:=abs(sin(2*Angle*pi/180));
  c2:=abs(sin(3*Angle*pi/180));
  c3:=abs(sin(4*Angle*pi/180));

  Acolor[0]:=c1; Acolor[1]:=c2; Acolor[2]:=0;
  Bcolor[0]:=c1; Acolor[1]:=0; Acolor[2]:=c3;
  Ccolor[0]:=0; Acolor[1]:=c2; Acolor[2]:=c3;
  Dcolor[0]:=c1; Acolor[1]:=c2; Acolor[2]:=c3;
  A1color[0]:=c2; Acolor[1]:=c3; Acolor[2]:=0;
  B1color[0]:=c2; Acolor[1]:=0; Acolor[2]:=c1;
  C1color[0]:=0; Acolor[1]:=c3; Acolor[2]:=c1;
  D1color[0]:=c3; Acolor[1]:=0; Acolor[2]:=c2;

  glBegin(GL_QUADS);
  glNormal3f(0.0, 0.0, 1.0);
  DrawColoredVertex(@Acoord, @Acolor); // A передня грань куба
  DrawColoredVertex(@Bcoord, @Bcolor); // B
  DrawColoredVertex(@Ccoord, @Ccolor); // C
  DrawColoredVertex(@Dcoord, @Dcolor); // D

  glNormal3f(1.0, 0.0, 0.0);
  DrawColoredVertex(@A1coord, @A1color); // A1 права грань куба
  DrawColoredVertex(@Acoord, @Acolor);   // A
  DrawColoredVertex(@Dcoord, @Dcolor);   // D
  DrawColoredVertex(@D1coord, @D1color); // D1

  glNormal3f(0.0, 0.0, -1.0);
  DrawColoredVertex(@B1coord, @B1color); // B1 задня грань куба
  DrawColoredVertex(@A1coord, @A1color); // A1
  DrawColoredVertex(@D1coord, @D1color); // D1
  DrawColoredVertex(@C1coord, @C1color); // C1

  glNormal3f(-1.0, 0.0, 0.0);
  DrawColoredVertex(@Bcoord, @Bcolor);   // B ліва грань куба
  DrawColoredVertex(@B1coord, @B1color); // B1
  DrawColoredVertex(@C1coord, @C1color); // C1
  DrawColoredVertex(@Ccoord, @Ccolor);   // C

  glNormal3f(0.0, 1.0, 0.0);
  DrawColoredVertex(@B1coord, @B1color); // B1 верхня грань куба
  DrawColoredVertex(@Bcoord, @Bcolor);   // B
  DrawColoredVertex(@Acoord, @Acolor);   // A
  DrawColoredVertex(@A1coord, @A1color); // A1

  glNormal3f(0.0, -1.0, 0.0);
  DrawColoredVertex(@C1coord, @C1color); // C1 нижня грань куба
  DrawColoredVertex(@Ccoord, @Ccolor);   // C
  DrawColoredVertex(@Dcoord, @Dcolor);   // D
  DrawColoredVertex(@D1coord, @D1color); // D1
  glEnd
end;
{
const n = 80; h = 2.0; r = 1.0;
var i:integer;
var fi,delta_fi,red,blue,green:real;
begin
  delta_fi:=2*pi/n; fi:=0.0;
  glDisable(GL_LIGHTING); //вимикаємо освітлення
  glBegin(GL_QUAD_STRIP); // пояс із 4-кутників
  for i:=0 to n do
  begin
    red:=abs(sin(2*Angle*pi/180));
    blue:=abs(sin(3*Angle*pi/180));
    glColor3f(red,0.0,blue); // колір нижніх вершин
    glVertex3f( R*cos(fi), R*sin(fi), -h/2); // 1
    red :=abs(sin(5*Angle*pi/180));
    blue:=abs(sin(7*Angle*pi/180));
    glColor3f(red,1.0,blue); // колір верхніх вершин
    glVertex3f( R*cos(fi), R*sin(fi), h/2); // 2
    fi:=fi+delta_fi
  end;
  glEnd
end;
}

procedure TFMain.FormCreate(Sender: TObject);
begin
  Angle:=0.0;

  DC:=GetDC(Handle);//одержуємо контекст пристрою
  SetDCPixelFormat(DC); // встановлюємо формат пікселя
  // створюємо контекст відтворення
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc); // робимо його основним
  glEnable (GL_LIGHTING); // включаємо освітлення
  glEnable (GL_LIGHT0); // включаємо джерело GL_LIGHT0
  //включаємо перевірку глибини зображення (z-буфер)
  glEnable (GL_DEPTH_TEST);
  //включаємо режим відтворення кольорів
  glEnable (GL_COLOR_MATERIAL);
  glClearColor(0.1,0.0,0.2,0.0); {колір фону}
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  // відключаємо контекст відтворення
  wglMakeCurrent(0, 0);
  //знищуємо контекст відтворення
  wglDeleteContext(hrc);
  //звільняємо контекст пристрою
  ReleaseDC (Handle,DC);
  DeleteDC (DC) {знищуємо контекст пристрою}
end;

procedure TFMain.FormPaint(Sender: TObject);
begin
  // очищення буферів зображення та глибини
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix; // запам’ятати модельну матрицю
  // задання положення камери в світових координатах
  gluLookAt(0.0,0.0,8.0, // позиція камери
            0.0,0.0,0.0, // напрям на центр сцени
            0.0,1.0,0.0);// напрям вертикалі
  // поворот на кут Angle навколо вектора (1,1,1)
  glRotatef(Angle, 1.0, 1.0, 1.0);
  Draw3D;

  glPopMatrix; // відновити модельну матрицю
  Angle:=Angle+1.0; // зміна кута для обертання сцени
  if Angle>=360.0 then Angle:=0.0
end;

procedure TFMain.FormResize(Sender: TObject);
const w=1.5; // масштабуючий множник
begin
  // задаємо розміри вікна на формі
  glViewport(0,0, ClientWidth,ClientHeight);
  // встановлюємо видову матрицю (проектування)
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity; // завантажумо одиничну матрицю
  // задаємо об’єм видимості паралельної проекції
  glOrtho( // xmin, xmax, ymin, ymax, znear, zfar
          -w*ClientWidth/ClientHeight,
          w*ClientWidth/ClientHeight,-w, w, 1, 10 );
  // встановлюємо модельну матрицю
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity; // завантажуємо одиничну матрицю
  // перемальовування вікна
  InvalidateRect(Handle, nil, False)
end;

procedure TFMain.Timer1Timer(Sender: TObject);
begin
  //обмін зображення переднього і заднього буферів
  SwapBuffers(DC); // та перемальовування вікна
  InvalidateRect(Handle, nil, False)
end;

end.

