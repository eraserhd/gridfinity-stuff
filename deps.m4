m4_divert(-1)
m4_define(`m4_include',`
m4_divert(0)m4_dnl
m4_TARGET: `$1'
m4_divert(-1)
m4_builtin(`include', `$1')m4_dnl
')
