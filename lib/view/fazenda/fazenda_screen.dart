import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:i_farm_net_new/controller/fazenda/fazenda_controller.dart';
import 'package:i_farm_net_new/model/fazendeiro_model.dart';
import 'package:i_farm_net_new/model/missoes_model.dart';
import 'package:i_farm_net_new/model/pergunta_model.dart';
import 'package:i_farm_net_new/view/barra_navegacao_widget.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';




class FazendaScreen extends StatefulWidget {

  @override
  _FazendaScreenState createState() => _FazendaScreenState();

}

class _FazendaScreenState extends State<FazendaScreen> {


  @override
  Widget build(BuildContext context) {
    final controller= GetIt.I.get<FazendaController>();
    
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: new Scaffold(
            backgroundColor: Color.fromRGBO(49, 122, 45, 0.7),
            appBar: BarraNavegacao(),
            body:
            Stack(
              children: [
               Align(
                    alignment: FractionalOffset.bottomCenter,
                    child:  Image.asset("lib/view/assets/lago.png", excludeFromSemantics: true,),
                  ),

                Center(
                    child:

                    Column(
                      children: <Widget>[
                        Container(height: 40,),

                        Row(
                            children: <Widget>[
                              Container(width: 20),
                              Column(
                                children: <Widget>[
                                  Semantics(
                                      child: terreno(),
                                      label: "terreno",
                                      onTapHint: "evoluir o terreno",
                                  ),
                                  Container(height: 70,),
                                  Semantics(child: vaca(),label: "vaca", onTapHint: "ver opções da vaca",),
                                ],
                              ),
                              Container(width: 60,),
                              Column(
                                children:[
                                  GestureDetector(
                                      child: Semantics(
                                          child: Image.asset("lib/view/assets/celeiro.png",height: 100,),
                                          label: "Celeiro",
                                          onTapHint: "produtos disponíveis",
                                      ),
                                      onTap:() {
                                        showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return celeiro(context);
                                          },

                                        );
                                      }
                                  ),
                                  Container(height: 70,),
                                  GestureDetector(
                                      child: Semantics(
                                          child: Image.asset("lib/view/assets/poco.png",height:60),
                                          label:"poço",
                                          onTapHint: "coletar água",
                                      ),
                                      onTap: (){
                                        controller.adicionarAgua();
                                        showCupertinoModalPopup<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return aguaAdicionada(context);
                                          },
                                        );
                                      }
                                  )
                                ],
                              ),
                            ]
                        ),
                      ],
                    )),
              ],
            ),

        ),
      ),
    );
  }



  Widget aguaAdicionada(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      title:Text("Água adicionada", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      content: Image.asset("lib/view/assets/produtos/agua.png",height: 100,),
      actions: <Widget>[
        botaoModalVerificaMissao(context,Missoes.coletarAgua),
      ],
    );
  }



  Future<void> aparecerPergunta(Pergunta pergunta) async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pergunta.questao, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
          content: SingleChildScrollView(child: Column(children:alternativasPergunta(pergunta))),
        );

      },
    );
  }

  List<Widget> alternativasPergunta(Pergunta pergunta){
    List<Widget> alternativas = [];

    for (String alternativa in pergunta.alternativas){
      alternativas.add(
          ButtonTheme(
            minWidth: 400,
            buttonColor: Colors.grey,
            child: RaisedButton(
              child: Text(alternativa),
              onPressed: (){
                Navigator.of(context).pop();
                evoluiOuMorre(alternativa, pergunta.respostaCorreta);

              },
            ),
          )
      );

    }

    return alternativas;


  }

  Widget terreno(){
    final controller= GetIt.I.get<FazendaController>();

    int numeroPergunta = 0;
    Perguntas perguntas = Perguntas.fromJSON(jsonPerguntas);
    Pergunta pergunta = perguntas.listaPerguntas[controller.fazendeiro.ordemPerguntas[numeroPergunta]];


    return Stack(
      children: [
        Image.asset("lib/view/assets/plantacao/cercaplantacoes.png", width: 90.0),
        GestureDetector(
            child: Observer(builder: (_){
              double altura = 110.0;
              String cultivoAtual = controller.fazendeiro.cultivoAtual;
              if (cultivoAtual == null|| controller.estadoAtual == "vazio")
                return Image.asset("lib/view/assets/plantacao/"+controller.estadoAtual+".png",height: altura,);
              return Image.asset("lib/view/assets/plantacao/"+cultivoAtual+"/"+controller.estadoAtual+".png",height: altura,);}),
            onTap:(){


              if (controller.fazendeiro.agua <= 0){
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return avisoSemAgua(context);
                  },
                );
              }

              else if (controller.estadoAtual == "morta"){
                if(controller.fazendeiro.adubo <= 0)
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return avisoSemAdubo(context);
                    },
                  );
                else{
                  controller.utilizarAdubo();
                  controller.evoluirTerreno();
                }
              }

              else if (controller.estadoAtual == "vazio"){
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return  aparecerOpcoesCultivo(controller.fazendeiro.nomeProdutos,context);
                  },
                );

              }

              else if (controller.estadoAtual == "completo"){
                controller.evoluirTerreno();
                controller.adicionarItem(controller.fazendeiro.cultivoAtual);
                controller.adicionarItem(controller.fazendeiro.cultivoAtual);
                if(controller.checarMissao(Missoes.colherAlimento)){
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return missaoConcluida(context);
                    },
                  );
                }
              }

              else if (controller.estadoAtual != "vazio") {
                aparecerPergunta(pergunta);
                numeroPergunta++;
                pergunta = perguntas.listaPerguntas[numeroPergunta];
                if (numeroPergunta==120){
                  numeroPergunta=0;
                  controller.fazendeiro.gerarListaOrdemPerguntas();
                }

              }

            }

        )],
    );

  }


  Widget avisoSemAdubo(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      title:Text("Acabou o adubo! Clique na vaca para recolher o adubo", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      content: Image.asset("lib/view/assets/animal/vaca.png",height: 100,),
      actions: <Widget>[
        botaoModal(context),
      ],
    );
  }





  Widget avisoSemAgua(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      title:Text("Acabou a água para irrigar! Clique no poço para pegar mais", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      content: Image.asset("lib/view/assets/poco.png",height: 100,),
      actions: <Widget>[
        botaoModal(context),
      ],
    );
  }


  Widget vaca(){
    return GestureDetector(
      onTap: (){
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return modalVaca(context);
          },

        );

      },
      child: Stack(
        children: [
          Image.asset("lib/view/assets/animal/cerca_animal.png",height: 60,),
          Column(
            children: <Widget>[
              Container(height: 10,),
              Row(
                children: <Widget>[
                  Image.asset("lib/view/assets/animal/comedourobebedouro.png",height: 20,),
                  GestureDetector(
                    child: Image.asset("lib/view/assets/animal/vaca.png",height: 40,),
                  ),
                ],
              ),
            ],
          )



        ],

      ),
    );

  }

  Widget modalVaca(BuildContext context){
    final controller= GetIt.I.get<FazendaController>();

    if (controller.fazendeiro.fomeVaca<=0)
      return AlertDialog(
        backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
        content: Container(
          height: 200,
          child: Column(
            children:[
              Text("A vaca está com fome! alimente-a com ração para produzir mais leite ou mais adubo!", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              //aaaaaaaaaaaaa
              Image.asset("lib/view/assets/animal/vaca.png",height: 60,),

              RaisedButton(
                child:Text("Alimentar Vaca"),
                onPressed: (){
                  Navigator.of(context).pop();
                  controller.produzirAdubo();
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) {
                      List<String> cultivos = controller.fazendeiro.nomeProdutos;
                      return alimentarVaca(cultivos,context);
                    },
                  );
                },
              ),

            ],
          ),
        ),
        actions: <Widget>[
          botaoModal(context)
        ],
      );



    return AlertDialog(
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      content: Container(
        height: 250,
        child: Column(
          children:[
            Image.asset("lib/view/assets/animal/vaca.png",height: 60,),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: new LinearPercentIndicator(
                width: 150,
                animation: true,
                lineHeight: 20.0,
                animationDuration: 20,
                percent: controller.fazendeiro.fomeVaca/5,
                center: Text(""),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.greenAccent,
              ),
            ),
            RaisedButton(
                child: Text("Coletar Leite",),
                onPressed: (){
                  controller.fazendeiro.fomeVaca--;
                  Navigator.of(context).pop();
                  controller.coletarLeite();
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return leiteAdicionado(context);
                    },
                  );
                }
            ),
            RaisedButton(
              child:Text("Produzir Adubo"),
              onPressed: (){
                controller.fazendeiro.fomeVaca--;
                Navigator.of(context).pop();
                controller.produzirAdubo();
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return aduboAdicionado(context);
                  },
                );
              },
            ),

          ],
        ),
      ),
      actions: <Widget>[
        botaoModal(context)
      ],
    );

  }

  Widget alimentarVaca(List<String> cultivos,BuildContext context) {
    Fazendeiro fazendeiro = Fazendeiro();
    Widget botoesCultivos = _gerarOpcoesAlimentarVaca();

    if(fazendeiro.racao<=0){
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
        title:Text("Acabou a ração! troque um cultivo por ração para alimentar a vaca", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        content: Image.asset("lib/view/assets/produtos/racao.png",height: 100,),
        actions: <Widget>[
          botaoModal(context),
        ],
      );
    }

    else {
      return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          title: Text("Dê a ração para a vaca", textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),),
          backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
          content: Container(
            height: 200,
            child: Column(
                children: [botoesCultivos]
            ),
          ));
    }

  }


  Widget _gerarOpcoesAlimentarVaca() {
    final controller= GetIt.I.get<FazendaController>();
    List<Widget> widgetsCultivo = [];
     return RaisedButton(
          child: Row(
            children: <Widget>[
              Image.asset("lib/view/assets/produtos/racao.png",height: 10,),
              Text("ração"),
            ],
          ),

          onPressed: () {
            controller.fazendeiro.fomeVaca=5;
            controller.utilizarRacao();
            Navigator.of(context).pop();
            showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) {
                return modalVaca(context);
              },
            );

          });
      }







  Widget aduboAdicionado(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      title:Text("Adubo Adicionado", textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      content: Image.asset("lib/view/assets/produtos/adubo.png",height: 100,),
      actions: <Widget>[
        botaoModalVerificaMissao(context,Missoes.gerarAdubo),
      ],
    );
  }

  Widget leiteAdicionado(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      title:Text("Leite Adicionado", textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      content: Image.asset("lib/view/assets/produtos/leite.png",height: 100,),
      actions: <Widget>[
        botaoModalVerificaMissao(context,Missoes.coletarLeite),
        
      ],
    );
  }







  Widget aparecerOpcoesCultivo(List<String> cultivos,BuildContext context) {
    Fazendeiro fazendeiro = Fazendeiro();
    List<Widget> botoesCultivos = _gerarOpcoesCultivos(cultivos);

    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        title:Text("Selecione um Cultivo", textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
        content: Container(
          height: 200,
          child: Column(
              children: botoesCultivos
          ),
        ));

  }


  List<Widget> _gerarOpcoesCultivos(List<String> cultivos) {
    final controller= GetIt.I.get<FazendaController>();
    List<Widget> widgetsCultivo = [];
    for (String cultivo in cultivos) {
      if (controller.fazendeiro.colheitas.contains(cultivo)) {
        widgetsCultivo.add(RaisedButton(
          child: Row(
            children: <Widget>[
              Image.asset("lib/view/assets/produtos/" + cultivo + ".png",height: 10,),
              Text(cultivo),
            ],
          ),

          onPressed: () {
            controller.evoluirTerreno();
            controller.fazendeiro.cultivoAtual = cultivo;
            Navigator.of(context).pop();
            controller.retirarItem(controller.fazendeiro.cultivoAtual);
          },));
      }
    }
    return widgetsCultivo;
  }


  Widget evoluiOuMorre(String respostaSelecionada,String repostaEsperada){
    final controller= GetIt.I.get<FazendaController>();
    if (respostaSelecionada == repostaEsperada){
      controller.evoluirTerreno();
      controller.adicionarValorItemSaude("sabedoria", 1);
      controller.adicionarValorItemSaude("vigorfísico", -5);
      controller.adicionarValorItemSaude("fome", -6);
      controller.utilizarAgua();
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return respostaCorreta(context);
        },
      );
    }
    else{
      controller.matarTerreno();
      controller.adicionarValorItemSaude("fome", -9);
      controller.adicionarValorItemSaude("vigorfísico", -3);
      controller.utilizarAgua();
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) {
          return respostaErrada(context);

        },
      );

    }

  }

  Widget respostaCorreta(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      title:Text("Resposta Correta! Sua planta desenvolveu!", textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      content: Image.asset("lib/view/assets/pergunta/certo.png",height: 100,),
      actions: <Widget>[
        botaoModal(context),
      ],
    );
  }

  Widget respostaErrada(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      title:Text("Resposta Incorreta! Sua planta morreu!", textAlign: TextAlign.center,style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      content: Image.asset("lib/view/assets/pergunta/errado.png",height: 100,),
      actions: <Widget>[
        botaoModal(context),
      ],
    );
  }







  List<Widget> gerarWidgetsItensCeleiro(List<String> produtos, List<int> quantidades){
    final controller= GetIt.I.get<FazendaController>();

    List<Widget> itensLista= []  ;
    int i=0;
    for (String itens in produtos){
      itensLista.add(
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop();
              showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return comerItemCeleiro(context,itens);
                  });

            },
            child: ListTile(
              leading: Image.asset("lib/view/assets/produtos/"+itens+".png", width: 50,),
              trailing: Text(quantidades[i].toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
              title: Text(StringUtils.capitalize(itens),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
            ),
          ));
      i++;
    }

    if (controller.fazendeiro.leite>0){
      itensLista.add(ListTile(
        leading: Image.asset("lib/view/assets/produtos/leite.png", height: 40,),
        trailing: Text(controller.fazendeiro.leite.toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
        title: Text("Leite",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      ));
    }


    itensLista.add(ListTile(
      leading: Image.asset("lib/view/assets/produtos/agua.png", height: 40,),
      trailing: Text(controller.fazendeiro.agua.toString(),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      title: Text("Água",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
    ));
    itensLista.add(ListTile(
      leading: Image.asset("lib/view/assets/produtos/adubo.png", height: 40,),
      trailing: Text(controller.fazendeiro.adubo.toString(), style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
      title: Text("Adubo",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
    ));
    itensLista.add(ListTile(
      leading: Image.asset("lib/view/assets/produtos/racao.png", height: 40,),
      trailing: Text(controller.fazendeiro.racao.toString(), style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
      title: Text("Ração",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
    ));


    return itensLista;
  }

  Widget comerItemCeleiro(BuildContext context,String itemSelecionado){
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5), //aqui!!!!!
      content: Container(
        height:150,
        child: Column(
          children: <Widget>[
            Text("Você gostaria de consumir "+itemSelecionado+"?",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
            Image.asset("lib/view/assets/produtos/" + itemSelecionado+ ".png", height: 100,),
          ],
        ),
      ),
      actions: <Widget>[
        botaoRecusa(context),
        botaoConfirma(context,itemSelecionado)
      ],
    );

  }

  Widget celeiro(BuildContext context) {
    final controller= GetIt.I.get<FazendaController>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),//aqui
      title:Text("Celeiro", textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      content: Column(
        children: gerarWidgetsItensCeleiro(controller.fazendeiro.nomeProdutos, controller.fazendeiro.quantidadeProdutos ),
      ),
      actions: <Widget>[
        botaoModal(context),
      ],
    );
  }

  Widget botaoModal(BuildContext context) {
    return Container(
      child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
            //mudar isso aqui
          },
          child: Text("OK", style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
    );
  }

  Widget botaoRecusa(BuildContext context) {
    return Container(
      child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Não", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
    ));
  }

  Widget botaoConfirma(BuildContext context,String alimento) {
    final controller= GetIt.I.get<FazendaController>();

    return Container(
      child: FlatButton(
          onPressed: () {
            controller.comer(alimento);
            if(controller.checarMissao(Missoes.comerAlimento)){
              showCupertinoModalPopup<void>(
                context: context,
                builder: (BuildContext context) {
                  return missaoConcluida(context);
                },
              );
            }

            Navigator.of(context).pop();
          },
          child:Text("Sim", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
    ));
  }


  Widget missaoConcluida(BuildContext context){
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      backgroundColor: Color.fromRGBO(125, 125, 125, 0.5),
      title:Text("Missão Concluída! Pegue sua nova missão!", textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
      content: Image.asset("lib/view/assets/barraPrincipal/missao.png",height: 100,),
      actions: <Widget>[
        botaoModalMissao(context),
      ],
    );
  }


  Widget botaoModalMissao(BuildContext context) {
    final controller= GetIt.I.get<FazendaController>();

    return Container(
      child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
            controller.fazendeiro.avisoNovaMissao=false;

          },
          child: Text("OK", style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
    );
  }


  Widget botaoModalVerificaMissao(BuildContext context, String missao) {
    final controller= GetIt.I.get<FazendaController>();

    return Container(
      child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (controller.checarMissao(missao)){
              showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return missaoConcluida(context);
                  });
            }

          },
          child: Text("ok", style:TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
      )
    );
  }



  final jsonPerguntas ={
    "perguntas": [{
      "questao": "Quanto tempo o tomate leva para ser cultivado ?",
      "alternativas": [
        "entre 90 e 110 dias",
        "entre 95 e 115 dias",
        "entre 200 e 250 dias",
        "entre 15 e 30 dias"
      ],
      "respostaCorreta": "entre 90 e 110 dias",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quanto tempo a batata leva para ser cultivada ?",
      "alternativas": [
        "entre 90 dias a 280 dias",
        "entre 15 dias a 20 dias",
        "entre 75 dias a 180 dias",
        "entre 65 dias a 700 dias"
      ],
      "respostaCorreta": "75 dias a 180 dias",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quanto tempo a mandioca leva para ser cultivada ?",
      "alternativas": [
        "entre 16 dias a 20 dias",
        "entre 7 meses a 5 anos",
        "entre 12 meses a 9 anos",
        "6 meses a 3 anos"
      ],
      "respostaCorreta": "6 meses a 3 anos",
      "assuntoPergunta": "cultivo"
    },
      {
        "questao": "Organismos vivos contribuem para a formação do solo com?",
        "alternativas": [
          "material orgânico em decomposição",
          "urbanização",
          "lixiviação",
          "assoreamento"
        ],
        "respostaCorreta": "material orgânico em decomposição",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual ser vivo contribue na escavação canais no solo?",
        "alternativas": [
          "Quero-quero",
          "Borboleta",
          "Tatu",
          "Minhoca"
        ],
        "respostaCorreta": "Minhoca",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual agente provoca a lixiviação?",
        "alternativas": [
          "Maresia",
          "Terremoto",
          "Chuva",
          "Homem"
        ],
        "respostaCorreta": "Chuva",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Quando a lixiviação é intensa e contínua, ela causa:",
        "alternativas": [
          "Laterização",
          "Falta de saneamento",
          "Superprodução",
          "Poluição do ar"
        ],
        "respostaCorreta": "Laterização",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual item não é um macronutriente essencial do solo?",
        "alternativas": [
          "Nitrogênio",
          "Fósforo",
          "Potássio",
          "Cálcio"
        ],
        "respostaCorreta": "Cálcio",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "O que é húmus?",
        "alternativas": [
          "Material inorgânico em decomposição",
          "Um alimento a base de soja",
          "Um sal",
          "Material orgânico em decomposição"
        ],
        "respostaCorreta": "Material orgânico em decomposição",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "O que é resíodo radioativo?",
        "alternativas": [
          "Restos de pilhas",
          "Água tônica",
          "Lixo derivado de peças de rádio",
          "Subproduto da energia nuclear"
        ],
        "respostaCorreta": "Subproduto da energia nuclear",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "O que é lixívia?",
        "alternativas": [
          "Lixiviação",
          "Aterros sanitários",
          "Saneamento básico",
          "Chorume"
        ],
        "respostaCorreta": "Chorume",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual o produto final da compostagem?",
        "alternativas": [
          "Adubo",
          "Material orgânico",
          "Desertificação",
          "Aço"
        ],
        "respostaCorreta": "Adubo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "A lata de lixo verde se destina para:",
        "alternativas": [
          "Madeira",
          "Vidro",
          "Papel",
          "Plástico"
        ],
        "respostaCorreta": "Vidro",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "A lata de lixo cinza se destina para:",
        "alternativas": [
          "Madeira",
          "Vidro",
          "Papel",
          "Plástico"
        ],
        "respostaCorreta": "Madeira",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "A lata de lixo vermelha se destina para:",
        "alternativas": [
          "Madeira",
          "Vidro",
          "Papel",
          "Plástico"
        ],
        "respostaCorreta": "Plástico",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "A lata de lixo azul se destina para:",
        "alternativas": [
          "Madeira",
          "Vidro",
          "Papel",
          "Plástico"
        ],
        "respostaCorreta": "Papel",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "A lata de lixo marrom se destina para:",
        "alternativas": [
          "Madeira",
          "Orgânico",
          "Papel",
          "Plástico"
        ],
        "respostaCorreta": "Orgânico",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas características pertencem as tundras?",
        "alternativas": [
          "Solo pobre em nutrientes",
          "Solo rico em nutrientes",
          "Fauna rica",
          "Flora rica"
        ],
        "respostaCorreta": "Solo pobre em nutrientes",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses biomas não ocorre na América Latina?",
        "alternativas": [
          "Floresta Ombrófila",
          "Formação Hermácea",
          "Deserto",
          "Tundra"
        ],
        "respostaCorreta": "Tundra",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses biomas é o predominante no Brasil?",
        "alternativas": [
          "Floresta Ombrófila",
          "Floresta Temperada",
          "Tundra",
          "Taiga"
        ],
        "respostaCorreta": "Floresta Ombrófila",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual paisagem natural é predominante na região norte?",
        "alternativas": [
          "Floresta Amazônica",
          "Mata Atlântica",
          "Pampas",
          "Caatinga"
        ],
        "respostaCorreta": "Floresta Amazônica",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual paisagem natural é predominante na região nordeste?",
        "alternativas": [
          "Floresta Amazônica",
          "Mata Atlântica",
          "Pampas",
          "Caatinga"
        ],
        "respostaCorreta": "Caatinga",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual paisagem natural é predominante no Pantanal?",
        "alternativas": [
          "Floresta Amazônica",
          "Mata Atlântica",
          "Cerrado",
          "Caatinga"
        ],
        "respostaCorreta": "Cerrado",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas áreas alagam durante as cheias dos rios?",
        "alternativas": [
          "Matas de igapós",
          "Matas de várzea",
          "Cerrado",
          "Matas de terra firme"
        ],
        "respostaCorreta": "Matas de várzea",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas áreas alagam durante todo o ano?",
        "alternativas": [
          "Matas de igapós",
          "Matas de várzea",
          "Cerrado",
          "Matas de terra firme"
        ],
        "respostaCorreta": "Matas de igapós",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas áreas não alaga?",
        "alternativas": [
          "Matas de igapós",
          "Matas de várzea",
          "Pantanal",
          "Matas de terra firme"
        ],
        "respostaCorreta": "Matas de terra firme",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens não é um nome dado as Pampas?",
        "alternativas": [
          "Pradarias Mistas",
          "Campos Sulinos",
          "Campos Gaúchos",
          "Matas de terra firme"
        ],
        "respostaCorreta": "Matas de terra firme",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Em qual dessas regiões se encontra as Pampas",
        "alternativas": [
          "Norte",
          "Sul",
          "Nordeste",
          "Sudeste"
        ],
        "respostaCorreta": "Sul",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Em qual dessas regiões se encontra o Lavrado",
        "alternativas": [
          "Norte",
          "Sul",
          "Nordeste",
          "Sudeste"
        ],
        "respostaCorreta": "Norte",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é um causador direto da chuva ácida?",
        "alternativas": [
          "Veículos automotores",
          "Indústrias",
          "Usinas Termelétricas",
          "Usinas Nucleares"
        ],
        "respostaCorreta": "Usinas Nucleares",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens é o maior emissor de gás carbônico no Brasil?",
        "alternativas": [
          "Agricultura",
          "Geração de energia",
          "Processos industriais",
          "Tratamento de resíduos"
        ],
        "respostaCorreta": "Agricultura",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses é o maior poluidor?",
        "alternativas": [
          "China",
          "Estados Unidos",
          "União Européia",
          "Brasil"
        ],
        "respostaCorreta": "China",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens não é uma fonte de energia limpa?",
        "alternativas": [
          "Hidrelétricas",
          "Usinas Geotérmicas",
          "Usinas Nucleares",
          "Usinas Termelétricas"
        ],
        "respostaCorreta": "Usinas Termelétricas",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses métodos é usado para gerar energia nas Termelétricas?",
        "alternativas": [
          "Calor do solo",
          "Luz solar",
          "Queima de carvão",
          "Ventos"
        ],
        "respostaCorreta": "Queima de carvão",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas fases do ciclo da água se refere as chuvas?",
        "alternativas": [
          "Evaporação",
          "Infiltração",
          "Absorção",
          "Precipitação"
        ],
        "respostaCorreta": "Precipitação",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas fases do ciclo da água causam os rios subterrâneos?",
        "alternativas": [
          "Evaporação",
          "Infiltração",
          "Absorção",
          "Precipitação"
        ],
        "respostaCorreta": "Infiltração",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é um extrato dos organismos aquáticos?",
        "alternativas": [
          "Nécton",
          "Venon",
          "Plâncton",
          "Bento"
        ],
        "respostaCorreta": "Venon",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma característica dos manguezais?",
        "alternativas": [
          "Solos alagados",
          "Solos ricamente oxigenados",
          "Solos instáveis",
          "Solos ricos em matéria orgânica"
        ],
        "respostaCorreta": "Solos ricamente oxigenados",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma divisão do ecossistema marítimo?",
        "alternativas": [
          "Zona manguezal",
          "Domínio bentônico",
          "Zona afótica",
          "Zona fótica"
        ],
        "respostaCorreta": "Zona manguezal",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses tem a maior porcentagem da população com acesso a água potável?",
        "alternativas": [
          "Países industrializados",
          "América Latina e Caribe",
          "Sul da Ásia",
          "África Subsaariana"
        ],
        "respostaCorreta": "Países industrializados",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Em qual desses itens é onde se gasta mais água em uma casa no Brasil?",
        "alternativas": [
          "Descarga",
          "Higiene corporal",
          "Lavagem de Roupa",
          "Cozinhar"
        ],
        "respostaCorreta": "Descarga",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses países se gasta mais água per capita?",
        "alternativas": [
          "Estados Unidos",
          "Argentina",
          "México",
          "Brasil"
        ],
        "respostaCorreta": "Estados Unidos",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Em qual dos países da América Latina mais se gasta água per capita?",
        "alternativas": [
          "Brasil",
          "Chile",
          "Argentina",
          "Peru"
        ],
        "respostaCorreta": "Argentina",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens não é consequências do acúmulo de sedimentos na água?",
        "alternativas": [
          "Redução da penetração de Luz",
          "Morte de animais aquáticos",
          "Aumento da água mineral potável",
          "Diminuição da vazão dos cursos de água"
        ],
        "respostaCorreta": "Aumento da água mineral potável",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas doenças não é transmitida pela água",
        "alternativas": [
          "Cólera",
          "Poliomielite",
          "Cisticercose",
          "COVID-19"
        ],
        "respostaCorreta": "COVID-19",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens é uma característica do tratamento primário do esgoto?",
        "alternativas": [
          "Remoção de resíduos sólidos na superfície",
          "Passagem por aeradores",
          "Processos químicos",
          "Ação de microorganismos"
        ],
        "respostaCorreta": "Remoção de resíduos sólidos na superfície",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens é uma característica do tratamento terciário do esgoto?",
        "alternativas": [
          "Remoção de resíduos sólidos na superfície",
          "Passagem por aeradores",
          "Processos químicos",
          "Ação de microorganismos"
        ],
        "respostaCorreta": "Processos químicos",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses itens é uma característica do tratamento secundário do esgoto?",
        "alternativas": [
          "Remoção de resíduos sólidos na superfície",
          "Passagem por aeradores",
          "Processos químicos",
          "Uso de cloro"
        ],
        "respostaCorreta": "Passagem por aeradores",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas regiões tem a maior porcentagem de casas ligadas a rede pública de esgoto?",
        "alternativas": [
          "Norte",
          "Sul",
          "Nordeste",
          "Sudeste"
        ],
        "respostaCorreta": "Sudeste",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas regiões tem a menor porcentagem de casas ligadas a rede pública de esgoto?",
        "alternativas": [
          "Norte",
          "Sul",
          "Nordeste",
          "Sudeste"
        ],
        "respostaCorreta": "Norte",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas não é uma alternativa para os resíduos orgânicos?",
        "alternativas": [
          "Fossa negra",
          "Fossa marítima",
          "Fossa séptica",
          "Biodigestor"
        ],
        "respostaCorreta": "Fossa marítima",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma das ideias de Charles Darwin?",
        "alternativas": [
          "Evolução das espécies",
          "Geração espontânea",
          "Ancestralidade Comum",
          "Seleção Natural"
        ],
        "respostaCorreta": "Geração espontânea",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é um aspecto do lamarckismo?",
        "alternativas": [
          "Geração espontânea",
          "Impulso interno",
          "Seleção natural",
          "Sequência linear"
        ],
        "respostaCorreta": "Seleção natural",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual dessas é a maior obra de Charles Darwin?",
        "alternativas": [
          "Crepúsculo",
          "Harry Potter",
          "A evolução do relevo da terra",
          "A origem das espécies"
        ],
        "respostaCorreta": "A origem das espécies",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é exemplo de microevolução?",
        "alternativas": [
          "Insetos e inseticidas",
          "Bactérias e antibióticos",
          "Melanismo industrial",
          "Adaptação"
        ],
        "respostaCorreta": "Adaptação",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "O que é a Meia-vida?",
        "alternativas": [
          "Um fóssil",
          "Metade do tempo médio de vida de um homem",
          "Metade do tempo necessário para a massa de um isótopo se torne outro",
          "50 anos"
        ],
        "respostaCorreta": "Metade do tempo necessário para a massa de um isótopo se torne outro",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses é um consumidor primário?",
        "alternativas": [
          "Grilo",
          "Rato",
          "Cobra",
          "Águia"
        ],
        "respostaCorreta": "Grilo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses é um consumidor secundário?",
        "alternativas": [
          "Grilo",
          "Rato",
          "Cobra",
          "Águia"
        ],
        "respostaCorreta": "Rato",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses é um produtor?",
        "alternativas": [
          "Grilo",
          "Rato",
          "Cobra",
          "Planta"
        ],
        "respostaCorreta": "Planta",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma simbiose?",
        "alternativas": [
          "Mutualismo",
          "Comensalismo",
          "Parasitismo",
          "Malabarismo"
        ],
        "respostaCorreta": "Malabarismo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma relação harmônica??",
        "alternativas": [
          "Mutualismo",
          "Comensalismo",
          "Parasitismo",
          "Protocooperação"
        ],
        "respostaCorreta": "Parasitismo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma relação desarmônica?",
        "alternativas": [
          "Mutualismo",
          "Competição",
          "Parasitismo",
          "Amensalismo"
        ],
        "respostaCorreta": "Mutualismo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é uma simbiose?",
        "alternativas": [
          "Mutualismo",
          "Comensalismo",
          "Parasitismo",
          "Malabarismo"
        ],
        "respostaCorreta": "Malabarismo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é um indicador de social e de saúde?",
        "alternativas": [
          "Taxa de desemprego",
          "Taxa de mortalidade infantil",
          "Taxa de mortalidade geral",
          "Taxa de produto externo"
        ],
        "respostaCorreta": "Taxa de produto externo",
        "assuntoPergunta": "Biologia"
      },
      {
        "questao": "Qual desses não é um fator abiótico?",
        "alternativas": [
          "Radiação solar",
          "Relevo",
          "Antropomorfismo",
          "Ressurgência"
        ],
        "respostaCorreta": "Antropomorfismo",
        "assuntoPergunta": "Biologia"
      }, {
        "questao": "O que você entende pelo termo agricultura familiar?",
        "alternativas": [
          "Fundo de alto risco de grandes investidores",
          "Modo de organização da prodrução agrícola por pequenos produtores, quando há unidade entre a gestão e o trabalho",
          "Capacidade de compra de toneladas de produtos",
          "Impacto da mudança climática do Brasil "
        ],
        "respostaCorreta": "Modo de organização da prodrução agrícola por pequenos produtores, quando há unidade entre a gestão e o trabalho",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "O que você entende pelo modelo patronal?",
        "alternativas": [
          "Aquele que utiliza trabalhadores contratados, com a gestão separada do trabalho",
          "Aquele que utiliza trabalhadores rurais, com a gestão unificada ao trabalho",
          "Aquele que utiliza trabalhadores contratados, com a gestão unificada ao trabalho",
          "Aquele que utiliza cooperadores, com a gestão unificada ao trabalho "
        ],
        "respostaCorreta": "Aquele que utiliza trabalhadores contratados, com a gestão separada do trabalho",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "De acordo com o Banco Mundial nos anos 2007 e 2008 o preço dos alimentos subiram em média 83%. O aumento dos produtos alimentícios acaba gerando ainda mais probeza e fome na população, colocando famílias em uma situação de vulnerabilidade. Há muitas causas para o aumento expressivo no preço dos alimentos. Cite algumas delas?",
        "alternativas": [
          "Maior demanda por combustíveis, especulação do mercado financeiro, revolução verde",
          "Maior demanda por combustíveis, especulação do mercado financeiro,distribuição dos estabelecimentos ",
          "Distribuição dos estabelecimentos, revolução verde, mudanças climáticas",
          "Aumento da demanda por alimentos, diminuição da terra, mudanças climáticas "
        ],
        "respostaCorreta": "Aumento da demanda por alimentos, diminuição da terra, mudanças climáticas",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "São exemplos de economia solidária: Associações, cooperativas, clubes de troca e grupos de produção. Ao jogar IFarmNet, em quais dos exemplos acima você estava inserido?",
        "alternativas": [
          "Associação e/ou Cooperativa",
          "Clube de troca e/ou Grupo de produção",
          "todas as categorias",
          "nenhuma das categorias"
        ],
        "respostaCorreta": "Clube de troca e/ou Grupo de produção",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "Todas as atividades abaixo são realizadas na economia solidária, quais delas você realiza ao jogar IFarmNet?",
        "alternativas": [
          "Produção de bens e serviços",
          "Comércio justo",
          "Consumo solidário e trocas",
          "Finanças solidárias"
        ],
        "respostaCorreta": "Consumo solidário e trocas",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "A ideia de desenvolvimento sustentáveltem sido cada vez mais discutida junto às questões que se referem ao crescimento econômico. De acodo com esse conceito, considera-se que:",
        "alternativas": [
          "o meio ambiente é fundamental para a vida humana e, portanto, deve ser intocável",
          "ocorre uma oposição entre desenvolvimento e proteção ao meio ambiente e, portanto, é inevitável que os riscos ambientais sustentem o crescimento econômico dos povos",
          "deve-se buscar uma forma de progresso socioeconômico que não comprometa o meio ambiente sem que, com isso, deixemos de utilizar os recursos nele disponíveis",
          "são as riquezas acumuladas nos países ricos, em prejuízo das antigas colônias durante a expansão colonial, que devem, hoje, sustentar o crescimento econômico dos povos"
        ],
        "respostaCorreta": "deve-se buscar uma forma de progresso socioeconômico que não comprometa o meio ambiente sem que, com isso, deixemos de utilizar os recursos nele disponíveis",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "O que é sustentabilidade?",
        "alternativas": [
          "é um termo usado para definir ações e atividades humanas que visam destruir a natureza",
          "é um termo usado para definir ações e atividades humanas que visam esgotar os recursos da natureza ",
          "é um termo usado para definir ações e atividades humanas que visam suprir as necessidades atuais dos seres humanos, comprometendo o futuro das próximas gerações",
          "é um termo usado para definir ações e atividades humanas que visam suprir as necessidades atuais dos seres humanos, sem comprometer o futuro das próximas gerações"
        ],
        "respostaCorreta": "é um termo usado para definir ações e atividades humanas que visam suprir as necessidades atuais dos seres humanos, sem comprometer o futuro das próximas gerações",
        "assuntoPergunta": "Sociologia"
      }, {
        "questao": "O que é meio ambiente?",
        "alternativas": [
          "Engloba todos os elementos vivos e não-vivos que estão relacionados com a vida na Terra. É tudo aquilo que nos cerca, como a água, o solo, a vegetação, o clima, os animais, os seres humanos, dentre outros",
          "É a proteção sem a intervenção humana. Significa a natureza intocável ",
          "objetivo de mitigar o impacto dos problemas ambientais",
          "É a proteção com uso racional da natureza, através do manejo sustentável"
        ],
        "respostaCorreta": "Engloba todos os elementos vivos e não-vivos que estão relacionados com a vida na Terra. É tudo aquilo que nos cerca, como a água, o solo, a vegetação, o clima, os animais, os seres humanos, dentre outros",
        "assuntoPergunta": "Biologia"
      }, {
        "questao": "Algumas posturas devem ser adotadas para um melhor desenvolvimento de tarefas diárias. Sobre o andar, assinale a alternativa correta",
        "alternativas": [
          " O calçado deve ser preferencialmente, com salto de altura mínima de 5 cm",
          "Ao pisar, deve-se primeiro apoiar a ponta do pé, depois a planta e em seguida o calcanhar ",
          "Olhar sempre para baixo",
          "A base e parte anterior do calçado devem ser estreitas"
        ],
        "respostaCorreta": "Ao pisar, deve-se primeiro apoiar a ponta do pé, depois a planta e em seguida o calcanhar",
        "assuntoPergunta": "Biologia"
      }, {
        "questao": "Solos saudáveis são fundamentais para os suprimentos de alimentos, combustíveis, fibras e até medicamentos, disse a Organização das Nações Unidas para Alimentação e Agricultura (FAO) […]. De acordo com a FAO, a América Latina e o Caribe têm as maiores reservas de terras cultiváveis do mundo; portanto, o cuidado e a preservação dos seus solos é fundamental para que a região alcance a meta de erradicação da fome. Existem várias técnicas nos sistemas de cultivo que permitem o uso do solo sem afetar a sua conservação, EXCETO:",
        "alternativas": [
          " terraceamento",
          "rotação de culturas ",
          "adubação orgânica",
          "fertilização química"
        ],
        "respostaCorreta": "fertilização química",
        "assuntoPergunta": "Biologia"
      }
    ]
  };

}



