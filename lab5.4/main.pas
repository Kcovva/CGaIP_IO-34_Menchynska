unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls, Vcl.Menus;

type
  TFMain = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure GenRGBATexture(bmp_file_name:string);
    procedure GenTwoTextures;
    procedure LoadBmpTexture(bmp_file_name:string);
  private
    { Private declarations }
    Angle:real;//=0.0;
    hrc:HGLRC;
    DC:HDC;
  public
    { Public declarations }
  end;

const tw=512; th=512; // розміри 2D-текстури
var // додати описання масиву до глобальних змінних
arrayRGBA: Array [0..th-1,0..tw-1,0..3] of GLubyte;
var TexArray:Array[0..1] of GLUint;//глобальна змінна

var Bmp:TBitmap;//для завантаження зображення
// масив для передачі кольорів в текстурний об'єкт
arrayRGB: Array [0..th-1, 0..tw-1, 0..2] of GLubyte;

var
  FMain: TFMain;

implementation

{$R *.dfm}

procedure glGenTextures (n: GLsizei;
textures: PGLuint); stdcall; external opengl32;
procedure glBindTexture (target: GLEnum;
texture: GLuint); stdcall; external opengl32;
procedure glDeleteTextures (n: GLsizei;
textures: PGLuint); stdcall; external opengl32;

procedure SetDCPixelFormat (hdc : HDC);
var pfd:TPixelFormatDescriptor; nPixelFormat:Integer;
begin
  FillChar (pfd, SizeOf (pfd), 0);
  pfd.dwFlags:=PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  nPixelFormat :=ChoosePixelFormat (hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd)
end;

procedure Draw3D;
const h=1.0; n=8; r=h*1.2;
var i:integer;
begin
  glBindTexture( GL_TEXTURE_2D, TexArray[0] );
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
  glEnable(GL_TEXTURE_2D);// вмикання текстурування
  glBegin(GL_QUADS);// режим виведення 4-кутників
  // передня грань куба
  glTexCoord2d (1, 1); glVertex3f( h, h, h); // A
  glTexCoord2d (0, 1); glVertex3f(-h, h, h); // B
  glTexCoord2d (0, 0); glVertex3f(-h, -h, h); // C
  glTexCoord2d (1, 0); glVertex3f( h, -h, h); // D
  // права грань куба
  glTexCoord2d (1, 1); glVertex3f( h, h, -h); // A1
  glTexCoord2d (0, 1); glVertex3f( h, h, h); // A
  glTexCoord2d (0, 0); glVertex3f( h, -h, h); // D
  glTexCoord2d (1, 0); glVertex3f( h, -h, -h); // D1
  // задня грань куба
  glTexCoord2d (1, 1); glVertex3f(-h, h, -h); // B1
  glTexCoord2d (0, 1); glVertex3f( h, h, -h); // A1
  glTexCoord2d (0, 0); glVertex3f( h, -h, -h); // D1
  glTexCoord2d (1, 0); glVertex3f(-h, -h, -h); // C1
  // ліва грань куба
  glTexCoord2d (1, 1); glVertex3f(-h, h, h); // B
  glTexCoord2d (0, 1); glVertex3f(-h, h, -h); // B1
  glTexCoord2d (0, 0); glVertex3f(-h, -h, -h); // C1
  glTexCoord2d (1, 0); glVertex3f(-h, -h,  h); // C
  glEnd ;
  glBindTexture( GL_TEXTURE_2D, TexArray[1] );
  glTexEnvi(GL_TEXTURE_ENV,
  GL_TEXTURE_ENV_MODE, GL_BLEND);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
  glBegin(GL_TRIANGLE_FAN); glNormal3f(0.0, 1,0.0);
  glTexCoord2d (0.5, 0.5);glVertex3f(0.0, r,0.0);
  for i:=0 to n do
  begin
    glTexCoord2d (0.5+0.5*cos(i*2*pi/n),
                  0.5+0.5*sin(i*2*pi/n));
    glVertex3f(r*cos(2*pi/n*i),h, r*sin(2*pi/n*i))
  end;
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
	GenTwoTextures();
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  glDeleteTextures (2, @TexArray);
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

procedure TFMain.GenRGBATexture(bmp_file_name:string);
var i,j:Integer;
begin
  bmp:=TBitmap.Create;//створення бітової матриці
  // зчитування зображення з файла
  bmp.LoadFromFile(bmp_file_name);
  for i := 0 to tw-1 do for j := 0 to th-1 do begin
    arrayRGBA[j,i,0]:=
          255-GetRValue(bmp.Canvas.Pixels[i,th-1-j]);
    arrayRGBA[j,i,1]:=
          255-GetGValue(bmp.Canvas.Pixels[i,th-1-j]);
    arrayRGBA[j,i,2]:=
          255-GetBValue(bmp.Canvas.Pixels[i,th-1-j]);
    if (arrayRGBA[j,i,0]<10)AND(arrayRGBA[j,i,1]<10)AND
        (arrayRGBA[j,i,2]<10) then arrayRGBA[j,i,3]:=0
    else arrayRGBA[j,i,3]:=255;
  end;
  bmp.free; //звільнення пам'яті
  // автоматична побудова рівнів пірамідальної текстури
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, tw, th,
  GL_RGBA, GL_UNSIGNED_BYTE, @arrayRGBA);
  // задання способу збільшення текстури
  glTexParameteri(GL_TEXTURE_2D,
  GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // задання способу зменшення текстури
  glTexParameteri(GL_TEXTURE_2D,
  GL_TEXTURE_MIN_FILTER, GL_LINEAR)
end;

procedure TFMain.GenTwoTextures;
begin // створення масиву текстур
  glGenTextures( 2, @TexArray );
  // завантаження першої текстури
  glBindTexture( GL_TEXTURE_2D, TexArray[0] );
  // завантаження першої текстури
  LoadBmpTexture('..\..\images\grass.bmp');
  glBindTexture( GL_TEXTURE_2D, TexArray[1] );
  // завантаження другої текстури
  GenRGBATexture('..\..\images\flower.bmp')
end;

procedure TFMain.LoadBmpTexture(bmp_file_name:string);
var i,j:Integer;
begin
  bmp:=TBitmap.Create;//створення бітової матриці
  // зчитування зображення з файла
  bmp.LoadFromFile(bmp_file_name);
  for i := 0 to tw-1 do for j := 0 to th-1 do
  begin
      arrayRGB[j,i,0]:=GetRValue(bmp.Canvas.Pixels[i,th-1-j]);

      arrayRGB[j,i,2]:=GetBValue(bmp.Canvas.Pixels[i,th-1-j]);

      arrayRGB[j,i,1]:=GetGValue(bmp.Canvas.Pixels[i,th-1-j]);
  end;    bmp.Free; //звільнення пам'яті
          // створення текстури
  glTexImage2D(GL_TEXTURE_2D,// розмірність текстури
        0, // рівень текстури
        GL_RGBA, // формат відображення текселів
        tw, th, // розміри (ширина, висота)
        0, // розмір границі (рамки)
        GL_RGB, // формат елементів масиву
        GL_UNSIGNED_BYTE, // числовий тип
        @arrayRGB );//зв’язування з бітовим масивом
    // задання способу зменшення текстури
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // задання способу збільшення текстури
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    // задання способу обчислення кольорів об'єктів
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL)
end;

end.

