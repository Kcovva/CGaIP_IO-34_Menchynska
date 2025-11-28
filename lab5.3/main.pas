unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OpenGL, Vcl.ExtCtrls, Vcl.Menus, jpeg;

type
  TFMain = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Draw3D_43();
    procedure LoadJpegTextures;
  private
    { Private declarations }
    Angle:real;
    hrc:HGLRC;
    DC:HDC;
  public
    { Public declarations }
  end;

const n=4; // кількість зображень;
tw0=512; th0=512; // розміри одного зображення
tw=n*tw0; th=th0; // загальні розміри 2D-текстури

var Bmp:TBitmap;//для завантаження зображення
// масив для передачі кольорів в текстурний об'єкт
arrayRGB: Array [0..th-1, 0..tw-1, 0..2] of GLubyte;

var
  FMain: TFMain;

implementation

{$R *.dfm}

procedure SetDCPixelFormat (hdc : HDC);
var pfd:TPixelFormatDescriptor; nPixelFormat:Integer;
begin
  FillChar(pfd, SizeOf (pfd), 0);
  pfd.dwFlags :=PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  nPixelFormat :=ChoosePixelFormat (hdc, @pfd);
  SetPixelFormat(hdc, nPixelFormat, @pfd)
end;

procedure TFMain.Draw3D_43;// Текстурований куб (бічні грані)
const h=1.0;//h-половина довжини ребра куба
var s:GLfloat;// швидкість переміщення текстури
begin // вмикання механізму відображення текстури
  glEnable(GL_TEXTURE_2D); s:=Angle/360;
  glBegin(GL_QUAD_STRIP);// виведення смуги 4-кутників
  glTexCoord2d (0.0+s, 1); glVertex3f(-h, h, h); // B
  glTexCoord2d (0.0+s, 0); glVertex3f(-h, -h, h); // C
  glTexCoord2d (0.25+s, 1); glVertex3f( h, h, h); // A
  glTexCoord2d (0.25+s, 0); glVertex3f( h, -h,h); // D
  glTexCoord2d (0.5+s, 1); glVertex3f( h, h, -h); //A1
  glTexCoord2d (0.5+s, 0); glVertex3f( h, -h,-h); //D1
  glTexCoord2d (0.75+s, 1); glVertex3f(-h, h,-h); //B1
  glTexCoord2d (0.75+s, 0); glVertex3f(-h,-h,-h); //C1
  glTexCoord2d (1.0+s, 1); glVertex3f(-h, h, h); // B
  glTexCoord2d (1.0+s, 0); glVertex3f(-h, -h,h); // C
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
	LoadJpegTextures();
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  // відключаємо контекст відтворення
  wglMakeCurrent(0, 0);
  //знищуємо контекст відтворення
  wglDeleteContext(hrc);
  //звільняємо контекст пристрою
  ReleaseDC(Handle,DC);
  DeleteDC(DC) //знищуємо контекст пристрою
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
  Draw3D_43;
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

procedure TFMain.LoadJpegTextures;
var i,j,k: Integer; JPG: TJPEGIMAGE; fname:string;
begin
  for k:=1 to n do begin
    fname:='..\..\images\' + IntToStr(k)+'.jpg'; jpg := TJPEGImage.Create;
    try
      jpg.CompressionQuality := 100; {Default Value}
      jpg.LoadFromFile(FName);
      Bmp := TBitmap.Create; // створення бітової матриці
      Bmp.Width := tw0; Bmp.Height:= th0;
      // завантаження jpg-зображення з масштабуванням
      Bmp.Canvas.StretchDraw(Bmp.Canvas.Cliprect,jpg);
    Finally
      jpg.free;
    end;

    for i:=0 to tw0-1 do for j:=0 to th-1 do
    begin
      arrayRGB[j,i+(k-1)*tw0,0]:=
      GetRValue(bmp.Canvas.Pixels[i,th-1-j]);
      arrayRGB[j,i+(k-1)*tw0,1]:=
      GetGValue(bmp.Canvas.Pixels[i,th-1-j]);
      arrayRGB[j,i+(k-1)*tw0,2]:=
      GetBValue(bmp.Canvas.Pixels[i,th-1-j]);
    end;
    bmp.free; //звільнення пам'яті
  end;{for k}

  // автоматична побудова рівнів пірамідальної текстури
  gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, tw, th,
  GL_RGB, GL_UNSIGNED_BYTE, @arrayRGB);
  // задання способу збільшення текстури
  glTexParameteri(GL_TEXTURE_2D,
  GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // задання способу зменшення текстури
  glTexParameteri(GL_TEXTURE_2D,
  GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  // задання способу обчислення кольорів об'єктів
  glTexEnvi(GL_TEXTURE_ENV,
  GL_TEXTURE_ENV_MODE, GL_DECAL)
end;
end.

