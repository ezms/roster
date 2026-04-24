# TODO — Refatorações e pendências

## Código (mobile)

- [ ] Extrair `FlutterSecureStorage` para um singleton compartilhado — atualmente
      instanciado com as mesmas opções em `AuthController`, `HttpClient` e `GraphqlClient`
- [ ] Mover `_inputDecoration` para `lib/shared/widgets/` — função duplicada em
      `reports_screen.dart` e `super_admin_shell.dart`
- [ ] Substituir `Future.delayed(const Duration(seconds: 2))` hardcoded no
      `ScannerController` por uma constante nomeada
- [ ] Padronizar tratamento de erros nos controllers — alguns usam `catch (_)` silencioso,
      outros já têm `debugPrint`; definir uma estratégia única

## Regras de negócio pendentes (mobile + API)

- [ ] Esconder botão de iniciar chamada (scanner) para roles `admin` e `secretary` no app
- [ ] Proteger mutation `issueStudentCard` na API com `requireRole` para bloquear `teacher`
      (atualmente bloqueado só via UI)

## Endpoints da API sem uso no mobile

### REST
- `POST /auth/register` — criação de conta direta (atualmente via super admin)
- `GET /reports/classes/:classId` — relatório por turma (substituído pelo `attendanceReport` GraphQL)
- `POST /cards/:studentId/issue` e `GET /cards/:studentId` — duplicam a mutation GraphQL

### GraphQL — queries sem uso
- `student` (detalhe individual), `class` (detalhe individual)
- `attendanceSessions` (lista histórica de sessões)
- `attendanceRecords` (registros individuais de presença)
- `absentStudents`, `user` (detalhe individual)

### GraphQL — mutations sem uso
- `restoreStudent`, `restoreUser` — soft-delete reversal
- `addStudentToClass`, `removeStudentFromClass`, `transferStudentToClass`
- `createUser`, `updateUser`, `deleteUser`, `restoreUser` (gestão via super admin REST)
