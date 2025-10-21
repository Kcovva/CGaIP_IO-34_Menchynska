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

procedure TFMain.Draw3D;
const h=1.0; // �������� ������� ����� ����
begin
  glBegin(GL_QUADS);// ����� ��������� 4-�������
  // �������� ���� // ������ ������
  glColor3ub(180,0,250); glNormal3f(0.0, 0.0, 1.0);
  // ������ ������ ���� � �������� ������
  // ����� ����������� ������
  glVertex3f( h, h, h); // A ������� ����� ����
  glVertex3f(-h, h, h); // B (����� ��������)
  glVertex3f(-h, -h, h); // C
  glVertex3f( h, -h, h); // D
  glColor3ub(180,200,0); glNormal3f(1.0, 0.0, 0.0);
  glVertex3f( h, h, -h); // A1 ����� ����� ����
  glVertex3f( h, h, h); // A (����� ��������)
  glVertex3f( h, -h, h); // D
  glVertex3f( h, -h, -h); // D1
  glColor3ub(85,60,75); glNormal3f(0.0, 0.0, -1.0);
  glVertex3f(-h, h, -h); // B1 ����� ����� ����
  glVertex3f( h, h, -h); // A1 (����� ����������)
  glVertex3f( h, -h, -h); // D1
  glVertex3f(-h, -h, -h); // C1
  glColor3ub(50,165,255); glNormal3f(-1.0, 0.0, 0.0);
  glVertex3f(-h, h, h); // B ��� ����� ����
  glVertex3f(-h, h, -h); // B1 (����� ������� �����)
  glVertex3f(-h, -h, -h); // C1
  glVertex3f(-h, -h, h); // C
  glColor3ub(150,0,85); glNormal3f(0.0, 1.0, 0.0);
  glVertex3f(-h, h, -h); // B1 ������ ����� ����
  glVertex3f(-h, h, h); // B (����� ��������)
  glVertex3f( h, h, h); // A
  glVertex3f( h, h, -h); // A1
  glColor3ub(210,255,215); glNormal3f(0.0, -1.0, 0.0);
  glVertex3f(-h, -h, -h); // C1 ����� ����� ����
  glVertex3f(-h, -h, h); // C (����� ���������)
  glVertex3f( h, -h, h); // D
  glVertex3f( h, -h, -h); // D1
  glEnd
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
  Draw3D; // ������ ��������� �������� �ᒺ���

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

