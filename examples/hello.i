%module hello
%{
// ラッピングする関数のプロトタイプ宣言
void hello(const char *name);
%}
void hello(const char *name);
