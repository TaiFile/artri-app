# Análise do Aplicativo ArtriApp

**Integrantes:** 
- João Paulo Morais Rangel - 820827
- Vitor Taichi Taira       - 823838


**Versão analisada:** commit `d195993`

**Back-end:** `artri-app-api` rodando localmente via Docker (`docker-compose-local.yml`)


## Bugs Identificados

### Autenticação, Cadastro e Sessão

- **Cadastro não funciona:** o botão "ENVIAR" da tela de cadastro não possui ação alguma — nenhum usuário é criado e nenhum e-mail é enviado. O `onPressed` está vazio (`lib/views/sign_up_page/sign_up_page.dart:75`).
- **Recuperação de senha não funciona:** o botão "ENVIAR" da tela de recuperação também está sem ação (`lib/views/sign_up_page/send_password.dart:78`). O fluxo de "esqueci minha senha" é inteiramente inoperante.
- **Botão "ESQUECI MINHA SENHA" inerte:** na tela de login, o botão não navega para lugar nenhum (`lib/views/login_page/login_page.dart:82`).
- **Login sem qualquer feedback de erro:** ao errar usuário/senha, ou deixar campos vazios, o app não exibe alerta, mensagem ou indicação de carregamento — simplesmente nada acontece. A exceção é apenas registrada no console via `log()`, sem tratamento visível ao usuário (`lib/view_models/login.view_model.dart`). O usuário fica sem saber se o app travou, se a senha está errada ou se o servidor caiu.
- **Sessão não é mantida (usuário sempre deslogado):** ao reabrir o app, o usuário sempre cai na tela de login, mesmo tendo logado antes. A causa é uma condição de corrida em `lib/views/app.dart`: a rota inicial é decidida por `SecurityTokenService().userLoggedIn()`, uma chamada **síncrona**, enquanto o carregamento dos tokens do armazenamento seguro (`_initTokens()`) é **assíncrono** e ainda não terminou. Os campos verificados estão sempre vazios nesse instante, então a checagem retorna `false` em 100% dos casos.

### Crashes e Exceções

- **Exceção ao acessar Configurações (trocar e-mail / trocar senha):** os botões disparam uma exceção de rota do `go_router` e travam em uma tela de erro, exigindo reiniciar o app. Há duas causas somadas:
  1. O `SettingsRoutes.getGoRoutes()` **nunca é registrado** na árvore de rotas do app — as telas `ChangeEmailPage` e `ChangePasswordPage` existem mas estão órfãs, inalcançáveis.
  2. As constantes de destino (`'configuration/change-email'`, `'configuration/change-password'`) são caminhos **relativos, sem barra inicial**, enquanto o `context.go()` exige caminhos absolutos. Não existe nem rota pai `configuration` declarada.

### Persistência de Dados e Integração com o Back-end

- **Botão de salvar não executa ação alguma nas telas de Dor e Inchaço:** o callback de confirmação trata somente o caso "cancelar"; ao confirmar, a ação é literalmente `null` (`lib/views/user_diary/widgets/user_level_selection_with_options.dart:118` e `lib/views/user_diary/widgets/user_level_selection.dart:79`). Não há chamada ao back-end, mensagem ou navegação: o usuário toca em salvar e absolutamente nada acontece. Esta é a pior falha silenciosa do app — em um sistema de saúde, o paciente acredita ter registrado seu sintoma quando nada foi sequer enviado.
- **`DiaryViewModel` praticamente órfão:** a classe implementa os quatro métodos de envio (dor, fadiga, sono e inchaço), mas é efetivamente utilizada em **um único ponto de todo o aplicativo** (`lib/views/sleep/sleep_page.dart:102`). As demais telas do diário nunca a chamam, o que explica o item acima.
- **Registros do diário não são persistidos (tela de Sono):** a tela de Sono é a única ligada ao ViewModel e, diferentemente das outras, possui tratamento correto de interface (indicador de carregamento, SnackBar de sucesso/erro e retorno à tela anterior). Ainda assim, o envio **falha sempre** e o usuário recebe "Erro ao comunicar com o servidor", pois o `DiaryViewModel` (`lib/view_models/diary_view_model.dart`) possui três defeitos independentes, qualquer um deles suficiente para quebrar o salvamento:
  1. **Não envia autenticação:** a requisição define apenas o header `Content-Type`, sem nenhum `Authorization: Bearer <token>`. Como os endpoints são protegidos, toda tentativa retorna `401`.
  2. **Endpoints inexistentes:** chama `daily-sleep-report/`, `daily-pain-report/` etc. **no singular**, enquanto a API expõe essas rotas no plural (`daily-sleep-reports/`). Não se trata de defasagem: uma rota no singular **nunca existiu em nenhum momento** do histórico do back-end, ou seja, o endereço chamado jamais correspondeu a endpoint algum. Resultado: `404`.
  3. **Nomes de campo errados:** envia `'level'` e `'painLevel'`, enquanto os serializers esperam `'sleep_level'`, `'pain_level'` etc.

  Os próprios comentários no arquivo confirmam que o código é um placeholder não finalizado (_"Substitua 'daily-sleep-report/' pelo endpoint exato do seu urls.py"_, _"Confirme se o Serializer espera 'level' ou 'sleep_level'"_).
- **Gráfico "Sua Evolução" é totalmente falso:** os dados não vêm do back-end e não refletem nada do que o usuário registra. Os pontos estão fixos no código (`lib/views/evolution/evolution_page.dart`), como `const [FlSpot(0, 8), FlSpot(1, 6), ...]`.
- **Medicamentos são mockados:** a lista não vem da API. O `RemedyViewModel` simula uma chamada com `Future.delayed(Duration(seconds: 1))` e devolve uma lista fixa. O código traz o comentário explícito _"Dados mockados para teste enquanto você não pluga a URL final"_.
- **Checklist de medicamentos não persiste:** marcar um remédio como tomado só altera um `Map` em memória (`_checklistStatus`). Ao sair e voltar à tela, tudo aparece desmarcado novamente.

### Interface e Responsividade

- **Overflow na tela de Informações ao girar o dispositivo:** em orientação paisagem, a tela lança `RenderFlex overflowed by 248 pixels on the bottom` e o conteúdo fica inacessível. A `InfoPage` (`lib/views/info/info_page.dart`) é um `Center > Column` sem nenhum widget de rolagem, contendo 9 botões de altura fixa (50px) mais 8 espaçamentos de 16px — 578px de conteúdo rígido, contra os ~330px de altura disponíveis em paisagem. Como não há `SingleChildScrollView`, o excedente simplesmente não pode ser exibido nem alcançado.
- **Ausência de rolagem replicada em outras telas:** o mesmo padrão (`Column` sem widget de rolagem) aparece em `lib/views/user_diary/widgets/user_diary_initial_selection.dart` e `user_level_selection.dart`, deixando essas telas sujeitas ao mesmo tipo de overflow em dispositivos de tela menor ou em paisagem. A adoção de rolagem é inconsistente no projeto: a tela de seleção com opções (Dor/Inchaço) possui rolagem, enquanto as vizinhas não.
- **Funcionalidade de exercícios personalizados ausente:** o botão "Personalizados" existe, porém está **comentado** no código-fonte (`lib/views/physical_exercise/widgets/physical_exercise_home.dart`), embora a rota `customExercises` já esteja declarada. A feature está inacessível ao usuário.
- **Card de "Mitos e Verdades" sem ação:** o `onTap` do card está vazio (`lib/views/widgets/myth_truth_card.dart:160`).

---

## Potenciais Problemas

Itens que indicam risco arquitetural ou que dependem de validação no ambiente de teste.

- **Uso de `dart:io HttpClient` inviabiliza a versão Web:** o `DiaryViewModel` importa `dart:io` e usa `HttpClient`, que **não é suportado em Flutter Web**. Se o app for compilado para navegador, todo o módulo de diário quebra na importação. O restante do app usa o pacote `http`, que é multiplataforma — a inconsistência sugere código escrito às pressas e não integrado ao padrão do projeto.
- **Ausência sistemática de tratamento de erro visível:** o padrão `catch (e) { log(e) }` aparece em vários pontos. Falhas de rede, servidor fora do ar ou token expirado são indistinguíveis de "nada aconteceu" da perspectiva do usuário.
- **Sem estratégia de renovação de token:** não há nenhuma lógica que trate expiração do access token (o padrão do Simple JWT é de 5 minutos). Mesmo que a autenticação fosse corrigida, o app pararia de funcionar poucos minutos após o login, sem nenhuma indicação do motivo.
- **Código morto no repositório:** existem interceptadores (`AuthInterceptor`, `RefreshTokenPolicy`) implementados mas **nunca utilizados**, além de blocos inteiros comentados. Isso confunde a leitura do projeto e mascara o fato de a autenticação não estar ligada.
- **Tema de texto construído e descartado:** em `lib/views/app.dart`, a linha `ThemeData(textTheme: GoogleFonts.jetBrainsMonoTextTheme());` cria um tema e **descarta o resultado** — não é atribuída a nada nem repassada ao `MaterialApp`. O efeito pretendido (aplicar a fonte ao app) nunca ocorre, e a instrução não faz absolutamente nada.

---

## Sugestões de Melhorias

- **Rolagem por padrão em telas de conteúdo variável:** adotar `SingleChildScrollView` ou `ListView` nas telas com listas de botões e formulários. Resolveria de uma vez os overflows em paisagem e em dispositivos menores, sem precisar tratar tela a tela.
- **Feedback obrigatório em toda ação de rede:** padronizar três estados visíveis (carregando, sucesso, erro) para qualquer operação que fale com a API. Em um aplicativo de saúde, o usuário precisa ter certeza de que o registro do seu sintoma foi salvo.
- **Centralizar a autenticação em um cliente HTTP único:** em vez de cada serviço montar o header manualmente (ou esquecer de montar), injetar um único cliente já autenticado, com renovação automática de token. Elimina a classe inteira de bugs de "esqueci o Bearer" e aproveita os interceptadores que já existem no projeto.
- **Aumentar a área de toque no checklist de medicamentos:** permitir marcar o item tocando em qualquer ponto do card (nome, ícone, área toda), e não apenas no quadrado da caixa de seleção — especialmente relevante para o público-alvo do app, que pode ter limitação de mobilidade nas mãos.
- **Aviso antes de redirecionamento externo:** ao abrir links de referência no navegador, exibir um aviso rápido informando que o usuário sairá do aplicativo.
- **Permitir login por e-mail:** hoje só é aceito o nome de usuário; aceitar também o e-mail reduz o atrito de acesso.
- **Centralizar a tipografia em um tema:** o projeto possui **12 tamanhos de fonte distintos escritos diretamente nas telas** (16, 24, 14, 18, 20, 28, 32, 22, 50, 36, 30 e 64), sem nenhuma hierarquia definida. Convém extrair isso para o `textTheme` do `ThemeData` e referenciá-lo nas telas, garantindo consistência e permitindo respeitar a preferência de tamanho de fonte do sistema — algo especialmente relevante para o público-alvo do aplicativo.
- **Remover o código morto e os mocks:** eliminar blocos comentados e dados fixos, ou marcá-los claramente com `TODO`, para que o estado real de implementação de cada feature fique evidente.
