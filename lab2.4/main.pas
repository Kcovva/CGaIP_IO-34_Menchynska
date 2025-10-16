unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls, Vcl.Menus;

type
  TFMain = class(TForm)
    Timer1: TTimer;
    PopupMenu: TPopupMenu;
    A1: TMenuItem;
    B1: TMenuItem;
    C1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure A1Click(Sender: TObject);
  type
    TDrawMode = (dmPoint = 0, dmLine, dmPointAndSolid, dmPointAndLine, dmLineAndSilid);
  private
    { Private declarations }
    Angle:real;//=0.0;
    hrc:HGLRC;
    DC:HDC;
    DrawMode:TDrawMode;
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


procedure Draw3D(mode:GLenum);
const n = 16;// кількість бічних граней
      h = 1.0;// висота піраміди
      r = 0.5;// радіус описаного навколо основи кола
var i:integer;
    fi,delta_fi,teta:real;
begin
  delta_fi:=2*pi/n; teta:=arctan(h/r);
  fi:=0.0; // центральний кут основи піраміди

  //
  glPolygonMode(GL_FRONT_AND_BACK, mode);

  glPointSize(15.0);
  glEnable(GL_POINT_SMOOTH);

  glLineWidth(4.0);
  glEnable(GL_LINE_SMOOTH);

  glBegin(GL_TRIANGLES); // виведення трикутників
  for i:=1 to n do
  begin // власний колір для кожної грані
    if mode = GL_FILL then
      glColor3f(i mod 2,(i mod 3)/2,(i mod 5)/4)
    else
      glColor3f(1.0, 1.0, 1.0);

    glNormal3f(cos(fi+delta_fi/2)*sin(teta),
    sin(fi+delta_fi/2)*sin(teta), cos(teta)); // n
    glVertex3f( 0,0,h ); // v1
    glVertex3f( R*cos(fi), R*sin(fi), 0); // v2
    glVertex3f( R*cos(fi+delta_fi),
    R*sin(fi+delta_fi), 0); // v3
    fi:=fi+delta_fi // перехід до іншої грані
  end; {for і}
  glEnd;{ припинити виведення трикутників}

  fi := 0.0;
  glBegin(GL_POLYGON);
  glColor3f(1.0, 1.0, 1.0);
  glNormal3f(0, 0, -1);
  for i := 1 to n do
  begin
    glVertex3f(R * cos(fi), R * sin(fi), 0);
    fi := fi + delta_fi;
  end;
  glEnd;
end;


procedure TFMain.A1Click(Sender: TObject);
begin
  DrawMode := TDrawMode(TMenuItem(Sender).Tag);
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

  // виклик процедур побудови об’єктів
  case DrawMode of
    dmPoint :
      Draw3D(GL_POINT);
    dmLine :
      Draw3D(GL_LINE);
    dmPointAndSolid : begin
      Draw3D(GL_POINT);
      Draw3D(GL_FILL);
    end;
    dmPointAndLine : begin
      Draw3D(GL_POINT);
      Draw3D(GL_LINE);
    end;
    dmLineAndSilid : begin
      Draw3D(GL_LINE);
      Draw3D(GL_FILL);
    end;
  end;

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

