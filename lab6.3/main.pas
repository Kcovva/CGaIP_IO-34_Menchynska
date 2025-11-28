unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls, Vcl.Menus, System.Math;

type
  TFMain = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
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
  nPixelFormat:=ChoosePixelFormat (hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd)
end;

procedure TFMain.Draw3D;
const h=1.0;
begin
  glBegin(GL_QUADS);
  glColor3ub(255,0,0); glNormal3f(0.0, 0.0, 1.0);
  glVertex3f( h, h, h); // A передня грань куба
  glVertex3f(-h, h, h); // B
  glColor3ub(255,255,0); glNormal3f(0.0, 0.0, 1.0);
  glVertex3f(-h, -h, h); // C
  glVertex3f( h, -h, h); // D
  glColor3ub(255,0,0); glNormal3f(1.0, 0.0, 0.0);
  glVertex3f( h, h, -h); // A1 права грань куба
  glVertex3f( h, h, h); // A
  glColor3ub(255,255,0); glNormal3f(1.0, 0.0, 0.0);
  glVertex3f( h, -h, h); // D
  glVertex3f( h, -h, -h); // D1
  glColor3ub(255,0,0); glNormal3f(0.0, 0.0, -1.0);
  glVertex3f(-h, h, -h); // B1 задня грань куба
  glVertex3f( h, h, -h); // A1
  glColor3ub(255,255,0); glNormal3f(0.0, 0.0, -1.0);
  glVertex3f( h, -h, -h); // D1
  glVertex3f(-h, -h, -h); // C1
  glColor3ub(255,0,0); glNormal3f(-1.0, 0.0, 0.0);
  glVertex3f(-h, h, h); // B ліва грань куба
  glVertex3f(-h, h, -h); // B1
  glColor3ub(255,255,0); glNormal3f(-1.0, 0.0, 0.0);
  glVertex3f(-h, -h, -h); // C1
  glVertex3f(-h, -h, h); // C
  glColor3ub(255,0,0); glNormal3f(0.0, 1.0, 0.0);
  glVertex3f(-h, h, -h); // B1 верхня грань куба
  glVertex3f(-h, h, h); // B (червоне)
  glVertex3f( h, h, h); // A
  glVertex3f( h, h, -h); // A1
  glColor3ub(255,255,0); glNormal3f(0.0, -1.0, 0.0);
  glVertex3f(-h, -h, -h); // C1 нижня грань куба
  glVertex3f(-h, -h, h); // C (жовте)
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
var
  W, H: GLint; // розміри клієнтської області
  halfW, halfH: GLint;
  aspect: GLdouble;
  viewSize: GLdouble;
  fi, psi, f: GLfloat;
begin
  W := ClientWidth; H := ClientHeight;
  halfW := W div 2;
  halfH := H div 2;
  viewSize := 2.0;

  // загальні налаштування OpenGL
  glEnable(GL_SCISSOR_TEST);
  glEnable(GL_DEPTH_TEST);

  //----------------------------------------------------
  // Варіант #12
  //----------------------------------------------------
  // Верхній лівий кут. Ортографічна проекція, вид зліва
  glViewport(0, H - halfH, halfW, halfH);
  glScissor(0, H - halfH, halfW, halfH);
  glClearColor(0.9, 0.7, 0.8, 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  // Для ортографії задаємо куб [ -viewSize .. viewSize ] по X та Y, глибина [-20..20]
  glOrtho(-viewSize, viewSize, -viewSize, viewSize, -20.0, 20.0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  // камера ліворуч (вид зліва) (x = -8)
  gluLookAt(-8.0, 0.0, 0.0,   // eye
            0.0, 0.0, 0.0,    // center
            0.0, 1.0, 0.0);   // up
  Draw3D;

  //----------------------------------------------------
  // Верхній правий кут. Ортографічна проекція, вид ззаду
  glViewport(halfW, H - halfH, halfW, halfH);
  glScissor(halfW, H - halfH, halfW, halfH);
  glClearColor(0.8, 0.9, 0.7, 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  // Для ортографії задаємо куб [ -viewSize .. viewSize ] по X та Y, глибина [-20..20]
  glOrtho(-viewSize, viewSize, -viewSize, viewSize, -20.0, 20.0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  // камера ззаду (z = -8)
  gluLookAt(0.0, 0.0, -8.0,  // eye
            0.0, 0.0, 0.0,   // center
            0.0, 1.0, 0.0);  // up
  Draw3D;

  //----------------------------------------------------
  // Нижній лівий кут. Аксонометрична паралельна проекція
  // з поворотом на кути psi = 72 та fi = 72 градусів
  fi := 72.0;
  psi := 72.0;

  glViewport(0, 0, halfW, halfH);
  glScissor(0, 0, halfW, halfH);
  glClearColor(0.8, 0.8, 0.9, 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(-viewSize, viewSize, -viewSize, viewSize, -20.0, 20.0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  // Фронтальна камера
  gluLookAt(0.0, 0.0, 8.0,   // eye — фронтальна орто-камера
            0.0, 0.0, 0.0,   // center
            0.0, 1.0, 0.0);  // up

  // Застосуємо обертання для отримання аксонометричної проекції:
  glRotatef(psi, 0.0, 1.0, 0.0);
  glRotatef(fi, 1.0, 0.0, 0.0);
  Draw3D;

  //----------------------------------------------------
  // Нижній правий кут. Перспективна одноточкова проекція
  // з кутом огляду fi = 90 градусів
  glViewport(halfW, 0, halfW, halfH);
  glScissor(halfW, 0, halfW, halfH);
  glClearColor(0.9, 0.8, 0.8, 1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION); glPushMatrix;
  glLoadIdentity;

  aspect := halfW / max(1, halfH); // співвідношення сторін для цього viewport
  // fi = 90 градусів — кут огляду по вертикалі
  gluPerspective(90.0, aspect, 1.0, 100.0);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  // точка спостереження для перспективи (4.5,4.5,4.5)
  gluLookAt(4.5, 4.5, 4.5,   // eye
            0.0, 0.0, 0.0,   // center
            0.0, 1.0, 0.0);  // up

  // Вмикаємо нормалізацію нормалей при масштабуванні
  glEnable(GL_NORMALIZE);

  f := 3; // f > 1 збільшення, f < 1 зменшення
  glScalef(f, f, f);
  Draw3D;

  glMatrixMode(GL_PROJECTION); glPopMatrix;
  glMatrixMode(GL_MODELVIEW);

  glDisable(GL_SCISSOR_TEST);
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

