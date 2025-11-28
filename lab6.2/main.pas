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
    procedure Draw3D;
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

type C_Array=array[0..2]of GLfloat; // тип масиву
const // набір констант-векторів для кольорів
C_White : C_Array = (1.0,1.0,1.0); // білий
C_Black : C_Array = (0.0,0.0,0.0); // чорний
C_Grey : C_Array = (0.5,0.5,0.5); // сірий
C_DarcGrey:C_Array = (0.2,0.2,0.2); // темно-сірий
C_Red : C_Array = (1.0,0.0,0.0); // червоний
C_Green : C_Array = (0.0,1.0,0.0); // зелений
C_Blue : C_Array = (0.0,0.0,1.0); // голубий
C_DarcBlue:C_Array = (0.0,0.0,0.5); // синій
C_Cyan : C_Array = (0.0,1.0,1.0); // бірюзовий
C_Magenta: C_Array = (1.0,0.0,1.0); // бузковий
C_Yellow : C_Array = (1.0,1.0,0.0); // жовтий
C_Orange : C_Array = (0.1,0.5,0.0); //помаранчевий
C_Lemon : C_Array = (0.8,1.0,0.0); // лимонний
C_Brown : C_Array = (0.5,0.3,0.0); // коричневий
C_Navy : C_Array = (0.0,0.4,0.8); // електрик
C_Aqua : C_Array = (0.4,0.7,1.0); // блакитний
C_Cherry : C_Array = (1.0,0.0,0.5); // вишневий

implementation

uses DGLUT;

{$R *.dfm}

procedure SetDCPixelFormat (hdc : HDC);
var pfd:TPixelFormatDescriptor; nPixelFormat:Integer;
begin
  FillChar (pfd, SizeOf (pfd), 0);
  pfd.dwFlags:=PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  nPixelFormat :=ChoosePixelFormat (hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd)
end;

procedure DrawAxis;//зображення координатних півосей
begin
  glDisable (GL_LIGHTING);// вимикаємо освітлення
  glBegin(GL_LINES); glLineWidth(2.0);
  {список констант для кольорів в завданні 5.2}
  glColor3fv(@C_Red); glVertex3f(0.0,0.0,0.0);
  glVertex4f(1.0,0.0,0.0,0.0); // 0x
  glColor3fv(@C_Blue); glVertex3f(0.0,0.0,0.0);
  glVertex4f(0.0,1.0,0.0,0.0);// 0y
  glColor3fv(@C_Green); glVertex3f(0.0,0.0,0.0);
  glVertex4f(0.0,0.0,1.0,0.0);// 0z
  glEnd;
  glEnable (GL_LIGHTING); // вмикаємо освітлення
end;

procedure TFMain.Draw3D;// процедура побудови сцени
const // вектор з координатами джерела світла
pos:array[0..3]of GLfloat=(1,1,1,0);
begin
  glRotatef(Angle, 0.0,1.0,0.0);// поворот сцени
  // задання положення джерела світла
  glLightfv(GL_LIGHT0,GL_POSITION,@pos);
  DrawAxis; // зображення координатних напівосей
  // виведення предметів сцени
  glColor3fv(@C_Navy);// задаємо колір
  glutSolidTeapot(1.4); // малюємо об’єкт (чайник) 2.0
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
  //включаємо режиму відсікання
  glEnable(GL_SCISSOR_TEST);

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
var W,H:GLint;// розміри вікна
begin // W-ширина, H- висота зображення на екрані
  W:=ClientWidth; H:=ClientHeight;

  //Побудова ортографічної проекції на XOY
  //задання області виведення у вікні на екрані
  glViewport(0,H div 2+1,W div 2+1, H div 2+1);
  //задання області обрізання
  glScissor(0,H div 2+1,W div 2+1, H div 2+1);
  glClearColor(0.9,0.7,0.8,1);//задання кольору фону
  // очищення області на екрані заданим кольором
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;// поточна модельна матриця =>в стек
  // задання положення камери в світових координатах
  gluLookAt(0.0,0.0,8.0, // позиція камери
            0.0,0.0,0.0, // напрям на центр сцени
            0.0,1.0,0.0);// напрям вертикалі
  Draw3D; // малюємо предмети сцени
  glPopMatrix; // модельна матриця <= зі стеку

  //Побудова ортографічної проекції на XOZ
  glViewport(0,0,W div 2+1, H div 2+1);
  glScissor(0,0,W div 2+1, H div 2+1 );
  glClearColor(0.8, 0.9, 0.7,1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  gluLookAt(0.0,8.0,0.0, 0.0,0.0,0.0, 0.0,0.0,-1.0);
  Draw3D; glPopMatrix;

  //Побудова ортографічної проекції на YOZ
  glViewport(W div 2+1 , H div 2,W div 2 ,H div 2 );
  glScissor(W div 2+1 , H div 2, W div 2 ,H div 2 );
  glClearColor(0.8, 0.8, 0.9,0.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  gluLookAt(8.0,0.0,0.0, 0.0,0.0,0.0, 0.0,1.0,0.0);
  Draw3D; glPopMatrix;

  //Побудова ізометричної проекції
  glViewport(W div 2+1 , 0,W div 2 ,H div 2 );
  glScissor(W div 2+1 , 0, W div 2 ,H div 2 );
  glClearColor(0.9, 0.8, 0.8, 0.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix;
  gluLookAt(4.5,4.5,4.5, 0.0,0.0,0.0, 0.0,1.0,0.0);
  Draw3D; glPopMatrix;

  Angle:=Angle+1.0; // зміна кута повороту
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
