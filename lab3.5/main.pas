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
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure Draw3D_2_2;
    procedure Draw3D_2_3;
    procedure Draw3D_2_4;
    procedure Draw3D_2_5;
  type
    TDrawMode = (dm2_2 = 0, dm2_3, dm2_4, dm2_5);
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

procedure TFMain.Draw3D_2_2;
// ������� ������, ������, �����
const n = 80; h = 2.0; r = 1.0;
var i:integer;
fi,delta_fi,red,blue,green:real;
begin
  delta_fi:=2*pi/n; fi:=0.0;
  glDisable(GL_LIGHTING); //�������� ���������
  glBegin(GL_QUAD_STRIP); // ���� �� 4-�������
  for i:=0 to n do
  begin
    red:=abs(sin(2*Angle*pi/180));
    blue:=abs(sin(3*Angle*pi/180));
    glColor3f(red,0.0,blue); // ���� ����� ������
    glVertex3f( R*cos(fi), R*sin(fi), -h/2); // 1
    red :=abs(sin(5*Angle*pi/180));
    blue:=abs(sin(7*Angle*pi/180));
    glColor3f(red,1.0,blue); // ���� ������ ������
    glVertex3f( R*cos(fi), R*sin(fi), h/2); // 2
    fi:=fi+delta_fi
  end; {for i}
  glEnd
end;

procedure TFMain.Draw3D_2_3;
// (��� ����� n � ������� ������)
// ������� ������, ������, �����
const n = 40; h = 1.5; r = 1.0;
var i,k:integer; fi,delta_fi, red, blue, green:real;
begin
  red:=0; blue:=0;
  delta_fi:=2*pi/n; glDisable(GL_LIGHTING);
  for k:=0 to 1 do begin
    fi:=0.0;
    glBegin(GL_TRIANGLE_FAN); // ��������� ����������
    glColor3f(1-red,0.0,1-blue); // ���� ������� 0
    glVertex3f( 0,0,h-k*2*h ); // V0
    for i:=0 to n do
    begin
      red:=abs(sin(5*(Angle)*pi/180-fi));
      blue:=abs(sin(3*Angle*pi/180-fi));
      glColor3f(red,1-red,blue); // ���� ������
      glVertex3f( R*cos(fi), R*sin(fi), 0); // V1..Vn
      fi:=fi+delta_fi
    end;{for i}
    glEnd
  end {for k}
end;

procedure TFMain.Draw3D_2_4;
// ��� ����� n � ������ ������
const n = 90; h = 1.0; r1 = 1.0; r2=0.05;
var i,k:integer; fi,delta_fi,red,blue,green:real;
begin
  delta_fi:=2*pi/n; glDisable(GL_LIGHTING);
  for k:=0 to 1 do begin
    fi:=0.0;
    glBegin(GL_QUAD_STRIP);
    for i:=0 to n do
    begin
      red:=abs(sin(2*(Angle)*pi/180-fi));
      blue:=abs(sin(3*Angle*pi/180-fi));
      green:=abs(sin(Angle*pi/180+fi));
      glColor3f(red,green,blue);
      glVertex3f( R1*cos(fi), R1*sin(fi), -h+2*h*k);// 1
      red:=abs(sin(5*Angle*pi/180+fi));
      blue:=abs(sin(7*Angle*pi/180+fi));
      green:=abs(sin(3*Angle*pi/180+fi));
      glColor3f(red,green,blue);
      glVertex3f( R2*cos(fi), R2*sin(fi), 0); // 2
      fi:=fi+delta_fi
    end;{for i}
    glEnd
  end {for k}
end;

procedure TFMain.Draw3D_2_5;
const n = 80; // ������� ������
r = 1.0; h = 2.0; //����� ������ ������� (������)
var i:integer; fi,delta_fi,red,blue,green:real;
begin
  delta_fi:=2*pi/n; fi:=0.0;
  glBegin(GL_QUAD_STRIP);
  for i:=0 to n do
  begin
    red:=abs(sin(2*(Angle)*pi/180-fi));
    blue:=abs(sin(3*Angle*pi/180-fi));
    glColor3f(red,0.0,blue);// ���� ����� ������
    glVertex3f( R*cos(fi)*sin(angle*pi/180),
                R*sin(fi)*cos(angle*pi/180), -h/2); // 1
    red:=abs(sin(5*Angle*pi/180+fi));
    blue:=abs(sin(7*Angle*pi/180+fi));
    glColor3f(red,1.0,blue); // ���� ������ ������
    glVertex3f( R*cos(fi)*cos(angle*pi/180),
    R*sin(fi)*sin(angle*pi/180), h/2); // 2

    fi:=fi+delta_fi
  end;{for i}
  glEnd
end;

procedure TFMain.A1Click(Sender: TObject);
begin
  DrawMode := TDrawMode(TMenuItem(Sender).Tag);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
  Angle:=0.0;

  DC:=GetDC(Handle);//�������� �������� ��������
  SetDCPixelFormat(DC); // ������������ ������ ������
  // ��������� �������� ����������
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc); // ������ ���� ��������
  glEnable (GL_LIGHTING); // �������� ���������
  glEnable (GL_LIGHT0); // �������� ������� GL_LIGHT0
  //�������� �������� ������� ���������� (z-�����)
  glEnable (GL_DEPTH_TEST);
  //�������� ����� ���������� �������
  glEnable (GL_COLOR_MATERIAL);
  glClearColor(0.1,0.0,0.2,0.0); {���� ����}
  DrawMode := dm2_2;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  // ��������� �������� ����������
  wglMakeCurrent(0, 0);
  //������� �������� ����������
  wglDeleteContext(hrc);
  //��������� �������� ��������
  ReleaseDC (Handle,DC);
  DeleteDC (DC) {������� �������� ��������}
end;

procedure TFMain.FormPaint(Sender: TObject);
begin
  // �������� ������ ���������� �� �������
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glPushMatrix; // ���������� �������� �������
  // ������� ��������� ������ � ������� �����������
  gluLookAt(0.0,0.0,8.0, // ������� ������
            0.0,0.0,0.0, // ������ �� ����� �����
            0.0,1.0,0.0);// ������ ��������
  // ������� �� ��� Angle ������� ������� (1,1,1)
  glRotatef(Angle, 1.0, 1.0, 1.0);

  // ������ �������� �������� �ᒺ���
  case DrawMode of
    dm2_2 :
      Draw3D_2_2;
    dm2_3 :
      Draw3D_2_3;
    dm2_4 :
      Draw3D_2_4;
    dm2_5 :
      Draw3D_2_5;
  end;

  glPopMatrix; // �������� �������� �������
  Angle:=Angle+1.0; // ���� ���� ��� ��������� �����
  if Angle>=360.0 then Angle:=0.0
end;

procedure TFMain.FormResize(Sender: TObject);
const w=1.5; // ������������ �������
begin
  // ������ ������ ���� �� ����
  glViewport(0,0, ClientWidth,ClientHeight);
  // ������������ ������ ������� (������������)
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity; // ����������� �������� �������
  // ������ �ᒺ� �������� ���������� ��������
  glOrtho( // xmin, xmax, ymin, ymax, znear, zfar
          -w*ClientWidth/ClientHeight,
          w*ClientWidth/ClientHeight,-w, w, 1, 10 );
  // ������������ �������� �������
  glMatrixMode (GL_MODELVIEW);
  glLoadIdentity; // ����������� �������� �������
  // ���������������� ����
  InvalidateRect(Handle, nil, False)
end;

procedure TFMain.Timer1Timer(Sender: TObject);
begin
  //���� ���������� ���������� � �������� ������
  SwapBuffers(DC); // �� ���������������� ����
  InvalidateRect(Handle, nil, False)
end;

end.

