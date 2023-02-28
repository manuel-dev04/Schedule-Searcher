% 106454 Manuel Martins
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.



% ------------------------------- 1. Qualidade dos dados --------------------------------

% 1.1 eventosSemSalas(EventosSemSala) e verdade se EventosSemSala e uma lista, ordenada 
% e sem elementos repetidos, de IDs de eventos sem sala.

eventosSemSalas(EventosSemSala) :-
    findall(ID, evento(ID, _, _, _, semSala), Eventos),
    sort(Eventos, EventosSemSala).


% 1.2 eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) e verdade se EventosSemSala
% e uma lista, ordenada e sem elementos repetidos, de IDs de eventos sem sala 
% que decorrem em DiaDaSemana.

eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala) :-
    eventosSemSalas(Eventos), 
    findall(ID, (member(ID, Eventos), horario(ID, DiaDaSemana, _, _, _, _)), 
    UnsortedEventosSemSala),
    sort(UnsortedEventosSemSala, EventosSemSala).

    
% 1.3 eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) e verdade se ListaPeriodos
% e uma lista de periodos e EventosSemSala e uma lista, ordenada e sem 
% elementos repetidos, de IDs de eventos sem sala nos periodos de ListaPeriodos.

eventosSemSalasPeriodo(ListaPeriodos, EventosSemSala) :-
    eventosSemSalas(Eventos), 
    findall(ID, (member(ID, Eventos), (member(Periodo, ListaPeriodos),
horario(ID, _, _, _, _, Periodo)) ; 
(member(ID, Eventos), member(p1, ListaPeriodos), horario(ID, _, _, _, _, p1_2)) ; 
(member(ID, Eventos), member(p2, ListaPeriodos), horario(ID, _, _, _, _, p1_2)) ;
(member(ID, Eventos), member(p3, ListaPeriodos), horario(ID, _, _, _, _, p3_4)) ;
(member(ID, Eventos), member(p4, ListaPeriodos), horario(ID, _, _, _, _, p3_4)) ;
(member(ID, Eventos), member(p1_2, ListaPeriodos), horario(ID, _, _, _, _, p1)) ;
(member(ID, Eventos), member(p1_2, ListaPeriodos), horario(ID, _, _, _, _, p2)) ;
(member(ID, Eventos), member(p3_4, ListaPeriodos), horario(ID, _, _, _, _, p3)) ;
(member(ID, Eventos), member(p3_4, ListaPeriodos), horario(ID, _, _, _, _, p4))), 
UnsortedEventosSemSala),
    sort(UnsortedEventosSemSala, EventosSemSala).


% find_ids(Periodo, IDS) e um Predicado Auxiliar utilizado para encontrar os IDs dos 
% eventos que ocorrem num determinado periodo.

find_ids(Periodo, IDs) :- 
    findall(ID, ((horario(ID, _, _, _, _, Periodo)) ; 
(Periodo = p1, horario(ID, _, _, _, _, p1_2)) ; 
(Periodo = p2, horario(ID, _, _, _, _, p1_2)) ;
(Periodo = p3, horario(ID, _, _, _, _, p3_4)) ;
(Periodo = p4, horario(ID, _, _, _, _, p3_4)) ;
(Periodo = p1_2, horario(ID, _, _, _, _, p1)) ;
(Periodo = p1_2, horario(ID, _, _, _, _, p2)) ;
(Periodo = p3_4, horario(ID, _, _, _, _, p3)) ;
(Periodo = p3_4, horario(ID, _, _, _, _, p4))), UnsortedIDs),
    sort(UnsortedIDs, IDs).
    


% --------------------------------- 2. Pesquisas simples --------------------------------


% intersection([], _, []) e um predicado auxiliar utilizado para a interseccao de listas.

intersection([], _, []).
intersection([X|Xs], Y, [X|Zs]) :-
    member(X, Y),
    intersection(Xs, Y, Zs).
intersection([X|Xs], Y, Zs) :-
    \+ member(X, Y),
    intersection(Xs, Y, Zs).


% 2.1 organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) e verdade se
% EventosNoPeriodo e a lista, ordenada e sem elementos repetidos, de IDs dos eventos
% de ListaEventos que ocorrem no periodo Periodo.

organizaEventos(ListaEventos, Periodo, EventosNoPeriodo) :-
    find_ids(Periodo, IDs),
    intersection(ListaEventos, IDs, UnsortedEventosNoPeriodo),
    sort(UnsortedEventosNoPeriodo, EventosNoPeriodo).


% 2.2 eventosMenoresQue(Duracao, ListaEventosMenoresQue) e verdade se
% ListaEventosMenoresQue e a lista ordenada e sem elementos repetidos 
% dos identificadores dos eventos que tem duracao menor ou igual a Duracao.

eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    findall(ID, (horario(ID, _, _, _, DuracaoEvento, _), DuracaoEvento =< Duracao), 
    UnsortedListaEventosMenoresQue),
    sort(UnsortedListaEventosMenoresQue, ListaEventosMenoresQue).


% 2.3 eventosMenoresQueBool(ID, Duracao) e verdade se o evento identificado por ID
% tiver duracao igual ou menor a Duracao.

eventosMenoresQueBool(ID, Duracao) :-
    horario(ID, _, _, _, DuracaoEvento, _),
    DuracaoEvento =< Duracao.


% 2.4 procuraDisciplinas(Curso, ListaDisciplinas) e verdade se ListaDisciplinas e a lista
% ordenada alfabeticamente do nome das disciplinas do curso Curso.

procuraDisciplinas(Curso, ListaDisciplinas) :-
    findall(ID, (turno(ID, Curso, _, _)), IDs),
    findall(Disciplina, (member(ID, IDs), evento(ID, Disciplina, _, _, _)), 
    UnsortedListaDisciplinas),
    sort(UnsortedListaDisciplinas, ListaDisciplinas).


% qualSemestre(Disciplina, Semestre) e um predicado auxiliar que e verdade se
% Semestre = s1 e Disciplina e uma disciplina do primeiro semestre,
% e e verdade se Semestre = s2 e Disciplina e uma disciplina do segundo semestre.

qualSemestre(Disciplina, s1) :-
    evento(ID, Disciplina, _, _, _),
    (horario(ID, _, _, _, _, p1); 
    horario(ID, _, _, _, _, p2); 
    horario(ID, _, _, _, _, p1_2)).
qualSemestre(Disciplina, s2) :-
    evento(ID, Disciplina, _, _, _),
    (horario(ID, _, _, _, _, p3); 
    horario(ID, _, _, _, _, p4); 
    horario(ID, _, _, _, _, p3_4)).


% ehDisciplina(Disciplina, Curso) e um predicado auxiliar que e verdade se Disciplina
% for uma disciplina do curso Curso.

ehDisciplina(Disciplina, Curso) :-
    procuraDisciplinas(Curso, ListaDisciplinas),
    member(Disciplina, ListaDisciplinas).


% 2.5 organizaDisciplinas(ListaDisciplinas, Curso, Semestres) e verdade se Semestres
% e uma lista com duas listas. A lista na primeira posicao contem as disciplinas de
% ListaDisciplinas do curso Curso que ocorrem no primeiro semestre; idem para a lista na
% segunda posicao, que contem as que ocorrem no segundo semestre. 

organizaDisciplinas([], _, [[],[]]).
organizaDisciplinas([Disciplina|Disciplinas], Curso, [[Disciplina|Semester1],Semester2]) :-
    ehDisciplina(Disciplina, Curso),
    qualSemestre(Disciplina, s1),
    organizaDisciplinas(Disciplinas, Curso, [Semester1,Semester2]).
organizaDisciplinas([Disciplina|Disciplinas], Curso, [Semester1,[Disciplina|Semester2]]) :-
    ehDisciplina(Disciplina, Curso),
    qualSemestre(Disciplina, s2),
    organizaDisciplinas(Disciplinas, Curso, [Semester1,Semester2]).  


% 2.6 horasCurso(Periodo, Curso, Ano, TotalHoras) e verdade se TotalHoras for o numero
% de horas total dos eventos associadas ao curso Curso, no ano Ano e periodo Periodo 

horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    find_ids(Periodo, IDs),
    findall(ID, (turno(ID, Curso, Ano, _), member(ID, IDs)), IDsAno),
    sort(IDsAno, IDsAnoSorted),
    findall(Horas, (horario(ID, _, _, _, Horas, _), member(ID, IDsAnoSorted)), ListaHoras),
    sum_list(ListaHoras, TotalHoras).

% 2.7 evolucaoHorasCurso(Curso, Evolucao) e verdade se Evolucao for uma lista de tuplos 
% na forma (Ano, Periodo, NumHoras), em que NumHoras e o total de horas associadas ao 
% curso Curso, no ano Ano e periodo Periodo. 
% Evolucao devera estar ordenada por ano(crescente) e periodo.

evolucaoHorasCurso(Curso, Evolucao) :-
    findall((Ano, Periodo, NumHoras), 
    (member(Periodo, [p1, p2, p3, p4]), member(Ano, [1, 2, 3]), 
    horasCurso(Periodo, Curso, Ano, NumHoras)), UnsortedEvolucao),
    sort(UnsortedEvolucao, Evolucao).



% ----------------------------- 3. Ocupacao critica de Salas ----------------------------


% 3.1 ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas)
% e verdade se Horas for o numero de horas sobrepostas (lembrar que 0.5 representa 
% 30 minutos) entre o evento que tem inicio em HoraInicioEvento e fim em HoraFimEvento,
% e o slot que tem inicio em HoraInicioDada e fim em HoraFimDada. 
% Se nao existirem sobreposicoes o predicado deve falhar (false).

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    HoraInicioEvento =< HoraFimDada,
    HoraFimEvento >= HoraInicioDada,
    (HoraInicioEvento >= HoraInicioDada, Inicio = HoraInicioEvento ; Inicio = HoraInicioDada),!,
    (HoraFimEvento =< HoraFimDada, Fim = HoraFimEvento ; Fim = HoraFimDada),!,
    % Os Cortes acima foram utilizados pois facilitam o funcionamento
    % do predicado numHorasOcupadas e ocupacaoCritica
    Horas is Fim - Inicio.


% 3.2 numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras)
% e verdade se SomaHoras for o numero de horas ocupadas nas salas do tipo TipoSala, 
% no intervalo de tempo definido entre HoraInicio e HoraFim, no dia da semana DiaSemana, 
% e no periodo Periodo.

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :-
    find_ids(Periodo, IDs),
    salas(TipoSala, ListaSalas),
    findall(ID, (member(ID, IDs), member(Sala, ListaSalas), evento(ID, _, _, _, Sala),
    horario(ID, DiaSemana, HoraInicioEvento, HoraFimEvento, _, _),
    ocupaSlot(HoraInicio, HoraFim, HoraInicioEvento, HoraFimEvento, _)),
    IDsSala),
    sort(IDsSala, IDsSalasSorted),
    findall(Horas, (horario(ID, DiaSemana, HoraInicioEvento, HoraFimEvento, _, _),
    ocupaSlot(HoraInicio, HoraFim, HoraInicioEvento, HoraFimEvento, Horas),
    member(ID, IDsSalasSorted)), ListaHoras),
    sum_list(ListaHoras, SomaHoras).


% 3.3 ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) e verdade se Max for o numero 
% de horas possiveis de ser ocupadas por salas do tipo TipoSala, no intervalo 
% de tempo definido entre HoraInicio e HoraFim. Em termos praticos, assume-se que 
% Max e o intervalo tempo dado (HoraFim - HoraInicio), multiplicado pelo numero de 
% salas em jogo do tipo TipoSala.

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-
    salas(TipoSala, ListaSalas),
    length(ListaSalas, NumSalas),
    Max is (HoraFim - HoraInicio) * NumSalas.


% 3.4 percentagem(SomaHoras, Max, Percentagem) e verdade se Percentagem for a 
% divisao de SomaHoras por Max, multiplicada por 100.

percentagem(SomaHoras, Max, Percentagem) :-
    Percentagem is (SomaHoras / Max) * 100.


% 3.5 ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) e verdade se
% Resultados for uma lista ordenada de tuplos do tipo casosCriticos(DiaSemana, 
% TipoSala, Percentagem) em que DiaSemana, TipoSala e Percentagem sao, 
% respectivamente, um dia da semana, um tipo de sala e a sua percentagem de ocupacao,
% no intervalo de tempo entre HoraInicio e HoraFim, e supondo que a percentagem de
% ocupacao relativa a esses elementos esta acima de um dado valor critico (Threshold). 

ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados) :-
    findall(casosCriticos(DiaSemana, TipoSala, Percentagem),
    (salas(TipoSala, _),
    member(DiaSemana, [segunda-feira, terca-feira, quarta-feira, quinta-feira, sexta-feira]),
    ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
    member(Periodo, [p1, p2, p3, p4]),
    numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras),
    percentagem(SomaHoras, Max, PercentagemCalculada),
    PercentagemCalculada > Threshold,
    Percentagem is ceiling(PercentagemCalculada)), CasosCriticos),
    sort(CasosCriticos, Resultados).

 
% ------------------ 4. And now for something completely different... ------------------

% Nota: este exercico nao esta completo.

% cab1(NP, L), cab2(NP, L), honra(NP1, NP2, L), lado(NP1, NP2, L), naoLado(NP1, NP2, L),
% frente(NP1, NP2, L), naoFrente(NP1, NP2, L) e veRestricao(Restricao, L) sao
%  predicados auxiliares utilizados em ocupacaoMesa.

/*
cab1(NP, L) :-
    (L = [_, _, _, NP, _, _, _, _]). 
    

cab2(NP, L) :-
    (L = [_, _, _, _, NP, _, _, _]). 

honra(NP1, NP2, L) :-
    (cab1(NP1, L), L = [_, _, _, _, _, NP2, _, _]);
    (cab2(NP1, L), L = [_, _, NP2, _, _, _, _, _]).

lado(NP1, NP2, L) :-
    (L = [NP1, NP2, _, _, _, _, _, _]);
    (L = [NP2, NP1, _, _, _, _, _, _]);
    (L = [_, NP1, NP2, _, _, _, _, _]);
    (L = [_, NP2, NP1, _, _, _, _, _]);
    (L = [_, _, NP1, _, NP2, _, _, _]);
    (L = [_, _, NP2, _, NP1, _, _, _]);
    (L = [_, _, _, NP2, _, NP1, _, _]);
    (L = [_, _, _, NP1, _, NP2, _, _]):
    (L = [_, _, _, _, NP1, _, _, NP2]);
    (L = [_, _, _, _, NP2, _, _, NP1]);
    (L = [_, _, _, _, _, NP2, NP1, _]);
    (L = [_, _, _, _, _, NP1, NP2, _]);
    (L = [_, _, _, _, _, _, NP2, NP1]);
    (L = [_, _, _, _, _, _, NP1, NP2]).         


naoLado(NP1, NP2, L) :-
    \+ lado(NP1, NP2, L).
    
frente(NP1, NP2, L) :-
    (L = [NP1, _, _, _, _, NP2, _, _]);
    (L = [NP2, _, _, _, _, NP1, _, _]);
    (L = [_, NP1, _, _, _, _, NP2, _]);
    (L = [_, NP2, _, _, _, _, NP1, _]);
    (L = [_, _, NP1, _, _, _, _, NP2]);
    (L = [_, _, NP1, _, _, _, _, NP2]);
    (L = [_, _, _, NP1, NP2, _, _, _]);
    (L = [_, _, _, NP2, NP1, _, _, _]).
    

naoFrente(NP1, NP2, L) :-
    \+ frente(NP1, NP2, L).

veRestricao(Restricao, L) :-
    (Restricao =.. [Pred, NP1], 
    ( call(Pred, NP1, L)
    ));
    (Restricao =.. [Pred, NP1, NP2],
    ( call(Pred, NP1, NP2, L)
    )).

% ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) e verdade se
ListaPessoas for a lista com o nome das pessoas a sentar a mesa, ListaRestricoes
for a lista de restricoes a verificar (ver abaixo) e OcupacaoMesa for uma lista com tres listas,
em que a primeira contem as pessoas de um lado da mesa (X1, X2 e X3), a segunda as
pessoas a cabeceira (X4 e X5) e a terceira as pessoas do outro lado da mesa (X6, X7 e X8),
de modo a que essas pessoas sao exactamente as da ListaPessoas e verificam todas as
restricoes de ListaRestricoes. Podes assumir que vai haver uma e uma unica solucao.

ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) :-
    maplist(veRestricao, ListaRestricoes),
    OcupacaoMesa = [[X1, X2, X3], [X4, X5], [X6, X7, X8]].

*/



