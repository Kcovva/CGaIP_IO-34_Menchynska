unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls;

type
  TFMain = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
    Angle:real;//=0.0;
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

procedure Draw3D;
const h=1.0; // половина довжини ребра куба
begin
  glBegin(GL_QUADS);// режим виведення 4-кутників
  // активний колір // вектор нормалі
  glColor3f(1.0,0.0,0.0); glNormal3f(0.0, 0.0, 1.0);
  // перелік вершин грані з напрямом обходу
  // проти годинникової стрілки
  glVertex3f( h, h, h); // A передня грань куба
  glVertex3f(-h, h, h); // B (червоний колір)
  glVertex3f(-h, -h, h); // C
  glVertex3f( h, -h, h); // D
  glColor3f(0.0,0.0,1.0); glNormal3f(1.0, 0.0, 0.0);
  glVertex3f( h, h, -h); // A1 права грань куба
  glVertex3f( h, h, h); // A (синій колір)
  glVertex3f( h, -h, h); // D
  glVertex3f( h, -h, -h); // D1
  glColor3f(0.0,1.0,0.0); glNormal3f(0.0, 0.0, -1.0);
  glVertex3f(-h, h, -h); // B1 задня грань куба
  glVertex3f( h, h, -h); // A1 (зелений колір)
  glVertex3f( h, -h, -h); // D1
  glVertex3f(-h, -h, -h); // C1
  glColor3f(1.0,1.0,0.0); glNormal3f(-1.0, 0.0, 0.0);
  glVertex3f(-h, h, h); // B ліва грань куба
  glVertex3f(-h, h, -h); // B1 (жовтий колір)
  glVertex3f(-h, -h, -h); // C1
  glVertex3f(-h, -h, h); // C
  glColor3f(1.0,0.0,1.0); glNormal3f(0.0, 1.0, 0.0);
  glVertex3f(-h, h, -h); // B1 верхня грань куба
  glVertex3f(-h, h, h); // B
  glVertex3f( h, h, h); // A
  glVertex3f( h, h, -h); // A1
  glColor3f(1.0,1.0,1.0); glNormal3f(0.0, -1.0, 0.0);
  glVertex3f(-h, -h, -h); // C1 нижня грань куба
  glVertex3f(-h, -h, h); // C
  glVertex3f( h, -h, h); // D
  glVertex3f( h, -h, -h); // D1
  glEnd
end;

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
  glClearColor(0.1,0.0,0.2,0.0) {колір фону}
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
  Draw3D;// виклик процедури побудови об’єктів
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

