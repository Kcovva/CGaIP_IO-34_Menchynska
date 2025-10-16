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
const n = 16;// ������� ����� ������
      h = 1.0;// ������ ������
      r = 0.5;// ����� ��������� ������� ������ ����
var i:integer;
    fi,delta_fi,teta:real;
begin
  delta_fi:=2*pi/n; teta:=arctan(h/r);
  fi:=0.0; // ����������� ��� ������ ������

  //
  glPolygonMode(GL_FRONT_AND_BACK, mode);

  glPointSize(15.0);
  glEnable(GL_POINT_SMOOTH);

  glLineWidth(4.0);
  glEnable(GL_LINE_SMOOTH);

  glBegin(GL_TRIANGLES); // ��������� ����������
  for i:=1 to n do
  begin // ������� ���� ��� ����� ����
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
    fi:=fi+delta_fi // ������� �� ���� ����
  end; {for �}
  glEnd;{ ��������� ��������� ����������}

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
  glClearColor(0.1,0.0,0.2,0.0) {���� ����}
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

