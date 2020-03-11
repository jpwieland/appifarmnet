import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:i_farm_net_new/controller/fazenda/fazenda_controller.dart';
import 'package:i_farm_net_new/model/celeiro_model.dart';
import 'package:i_farm_net_new/model/pergunta_model.dart';
import 'package:i_farm_net_new/view/celeiro_screen.dart';


class FazendaScreen extends StatefulWidget {

  @override
  _FazendaScreenState createState() => _FazendaScreenState();

}

class _FazendaScreenState extends State<FazendaScreen> {
  final controller= FazendaController();
  List<String> nomeProdutos = ['cenoura'];
  List<int> quantidadeProdutos= [8];
  String cultivoAtual;
  List<String> colheitas = ['cenoura','tomate','morango','alface'];

  @override
  Widget build(BuildContext context) {
    //List<String> nomeProdutos= ["cenoura"];
    int numeroPergunta = 0;
    Perguntas perguntas = Perguntas.fromJSON(jsonPerguntas);
    Pergunta pergunta = perguntas.listaPerguntas[numeroPergunta];
    return new Scaffold(
        backgroundColor: Colors.lightGreen,

        body:
      Center(
        child:
            Column(
              children:[
               GestureDetector(
                 child: Observer(builder: (_){
                   if (cultivoAtual == null|| controller.estadoAtual == "vazio")
                     return Image.asset("lib/view/assets/plantacao/"+controller.estadoAtual+".png");
                   return Image.asset("lib/view/assets/plantacao/"+cultivoAtual+"/"+controller.estadoAtual+".png");}),
                   onTap:(){

                     if (controller.estadoAtual == "morta"){
                       controller.evoluirTerreno();
                     }

                     else if (controller.estadoAtual == "vazio"){
                     _aparecerOpcoesCultivo(nomeProdutos);
                     }

                     else if (controller.estadoAtual == "completo"){
                       controller.evoluirTerreno();
                       adicionarItem(cultivoAtual);
                       adicionarItem(cultivoAtual);


                     }

                     else if (controller.estadoAtual != "vazio") {
                       _aprecerPergunta(pergunta);
                       numeroPergunta++;
                       pergunta = perguntas.listaPerguntas[numeroPergunta];
                     }

                   }

               ),



                GestureDetector(
                    child: Image.asset("lib/view/assets/celeiro.png",height: 100,),
                    onTap:() {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return celeiro(context);
                        },

                      );
                    }
    ),
                Container(
                  height: 30,
                ),
                GestureDetector(
                    child: Image.asset("lib/view/assets/seta.png",height: 60,),
                  onTap: (){
                      _oferecerProdutoParaTroca();
                  },
                ),

                      ])));
  }


  Future<void> _aprecerPergunta(Pergunta pergunta) async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          //title: Text('Favorite Dessert'),
          message: Text(pergunta.questao),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text(pergunta.alternativas[0]),
              onPressed: () { evoluiOuMorre(pergunta.alternativas[0], pergunta.respostaCorreta);
                              Navigator.of(context).pop();
              },
            ),
            CupertinoActionSheetAction(
              child: Text(pergunta.alternativas[1]),
              onPressed: () { evoluiOuMorre(pergunta.alternativas[1], pergunta.respostaCorreta);
                          Navigator.of(context).pop();

              },
            ),
            CupertinoActionSheetAction(
              child: Text(pergunta.alternativas[2]),
              onPressed: () {evoluiOuMorre(pergunta.alternativas[2], pergunta.respostaCorreta);
              Navigator.of(context).pop();

              },
            ),
            CupertinoActionSheetAction(
              isDefaultAction: true,
              child: Text(pergunta.alternativas[3]),
              onPressed: () { evoluiOuMorre(pergunta.alternativas[3], pergunta.respostaCorreta);
              Navigator.of(context).pop();

              },
            ),
          ],
          //cancelButton: ,
        );
      },
    );
    }








  Future<void> _oferecerProdutoParaTroca() async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            message: Text("Qual desses produtos vocẽ gostaria de dar para ser trocado?"),
            actions: gerarListaProdutosDisponiveisParaTroca()
          //cancelButton: ,
        );
      },
    );
  }

  List<Widget> gerarListaProdutosDisponiveisParaTroca(){
    List<Widget> listaItensASerTrocado= [];
    for (String produto in nomeProdutos){
      listaItensASerTrocado.add(CupertinoActionSheetAction(
        child: Text(produto),
        onPressed: () {
          Navigator.of(context).pop();
          _sugerirProdutoAserTrocado(produto);
        },
      )
      );

    }
    return listaItensASerTrocado;
  }










  Future<void> _sugerirProdutoAserTrocado(String produtoAserTrocado) async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          //title: Text('Favorite Dessert'),
          message: Text("Qual desses produtos vocẽ gostaria de adquirir?"),
          actions: gerarListaProdutosASerTrocado(produtoAserTrocado)

          //cancelButton: ,
        );
      },
    );
  }

  List<Widget> gerarListaProdutosASerTrocado(String produtoAserDado){

    List<Widget> listaItensASerTrocado= [];
    for (String produto in colheitas){
        listaItensASerTrocado.add(CupertinoActionSheetAction(
          child: Text(produto),
          onPressed: () {
            trocaConcluida(produtoAserDado,produto);

            Navigator.of(context).pop();
          },
        )
        );

    }
    return listaItensASerTrocado;
  }


  Widget trocaConcluida(String produtoDado, String produtoRecebido) {

    retirarItem(produtoDado);
    if (nomeProdutos.contains(produtoRecebido))
      adicionarItem(produtoDado);
    else {
      nomeProdutos.add(produtoRecebido);
      quantidadeProdutos.add(1);
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      content: Row(
          children:[
            Image.asset("lib/view/assets/produtos/"+produtoDado+".png", width: 50,) ,
            Image.asset("lib/view/assets/seta.png"),
            Image.asset("lib/view/assets/produtos/"+produtoRecebido+".png", width: 50,) ,

          ]

      ),
      actions: <Widget>[
        BotaoModal(context),
      ],
    );
  }



  Future<void> _aparecerOpcoesCultivo(List<String> cultivos) async {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {


        return CupertinoActionSheet(
          //title: Text('Favorite Dessert'),
          message: Text("Selecione um cultivo"),
          actions: _gerarOpcoesCultivos(cultivos),

          //cancelButton: ,
        );
      },
    );

  }

  List<Widget>_gerarOpcoesCultivos (List<String> cultivos){

    List<Widget> widgetsCultivo = [];
    for (String cultivo in cultivos){
        widgetsCultivo.add(CupertinoActionSheetAction(
          child: Text(cultivo),
          onPressed:()  { controller.evoluirTerreno();
          cultivoAtual = cultivo;
          Navigator.of(context).pop();
          retirarItem(cultivoAtual);
          },
        ));


    }
    return widgetsCultivo;


  }


  void evoluiOuMorre(String respostaSelecionada,String repostaEsperada){
    if (respostaSelecionada == repostaEsperada){
      controller.evoluirTerreno();
    }
    else{
      controller.matarTerreno();
    }

  }


  List<Widget> gerarWidgetsItensCeleiro(List<String> produtos, List<int> quantidades){
    List<Widget> itensLista= []  ;
    int i=0;
    for (String itens in produtos){
      itensLista.add(ListTile(
        leading: Image.asset("lib/view/assets/produtos/"+itens+".png", width: 50,),
        trailing: Text(quantidades[i].toString()),
        title: Text(itens),
      ));
      i++;
    }
    return itensLista;
  }


//  List<Widget> gerarWidgetsItensCeleiro2(List<String> produtos, List<int> quantidades){
//    List<Widget> itensLista= []  ;
//    int i=0;
//    for (String item in produtos){
//      itensLista.add(Row(children: <Widget>[Image.asset("lib/view/assets/produtos/"+item+".png", width: 50,),Text(item + "  x"+quantidades[i].toString())],));
//      i++;
//    }
//    return itensLista;
//  }

  void adicionarItem(String nomeCultivo){
    int i=0;
    int posicaoSelecionada;
    for (String cultivo in nomeProdutos){
      if (cultivo == nomeCultivo)
        posicaoSelecionada=i;
      i++;
    }
    quantidadeProdutos[posicaoSelecionada]++;
  }

  void retirarItem(String nomeCultivo){
    int i=0;
    int posicaoSelecionada;
    for (String cultivo in nomeProdutos){
      if (cultivo == nomeCultivo)
        posicaoSelecionada=i;
      i++;
    }
    quantidadeProdutos[posicaoSelecionada]--;
  }

  Widget celeiro(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      title:Text("Celeiro", textAlign: TextAlign.start,),
      content: Column(children: gerarWidgetsItensCeleiro(nomeProdutos,quantidadeProdutos ),),
      actions: <Widget>[
        BotaoModal(context),
      ],
    );
  }

  Widget BotaoModal(BuildContext context) {
    return Container(
      child: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("ok", style: Theme
              .of(context)
              .textTheme
              .button,)),
    );
  }





  final jsonPerguntas = {
    "perguntas": [{
      "questao": " Qual a principal característica da economia solidária ?",
      "alternativas": [
        "Quem possuí mais recurso financeiro é a pessoa que deve coordenar o grupo",
        "Uma pessoa deve ser responsável por coordenar o grupo e por esse motivo ela é a pessoa que deve ganhar mais",
        "Igualdade entre as pessoas participantes do grupo",
        "resposta errada"
      ],
      "respostaCorreta": " Igualdade entre as pessoas participantes do grupo",
      "assuntoPergunta": "economia solidária"
    }, {
      "questao": "Quem é o líder dentro do modelo de economia solidária ?",
      "alternativas": [
        "A pessoa que teve o maior lucro no grupo deve liderar o grupo",
        "Ninguém, no modelo de economia solidária todos tem a mesma importância e estão no mesmo nível. Todos podem opinar nas decisões tomadas para o grupo",
        " Quem irá trabalhar mais horas deve liderar o grupo",
        "O líder do grupo é a pessoa cujo a família possuí mais recursos financeiros"
      ],
      "respostaCorreta": "Ninguém, no modelo de economia solidária todos tem a mesma importância e estão no mesmo nível. Todos podem opinar nas decisões tomadas para o grupo",
      "assuntoPergunta": "economia solidária"
    }, {
      "questao": "Quais pilares da economia solidária ?",
      "alternativas": [
        "solidariedade - igualdade -  cooperação",
        "lucro - hierarquia - disputa comercial",
        "solidariedade - igualdade - disputa comercial",
        "lucro - igualdade  - disputa comercial"
      ],
      "respostaCorreta": "solidariedade - igualdade -  cooperação",
      "assuntoPergunta": "economia solidária"
    }, {
      "questao": " Quais os alimentos possuem vitamina A ?",
      "alternativas": [
        "Semente de girassol",
        "Cenoura",
        "Avelã",
        "Castanha"
      ],
      "respostaCorreta": "Cenoura",
      "assuntoPergunta": "saúde do trabalhador"
    }, {
      "questao": "Qual a importância da vitamina A para a saúde ?",
      "alternativas": [
        "Participa da absorção e utilização de dois sais importantes: o cálcio e o fósforo.",
        "Atua como antioxidante.",
        "Apresenta importante papel na visão, atua na manutenção de tecidos epiteliais e imunidade",
        "Possui importante papel na coagulação sanguínea."
      ],
      "respostaCorreta": "Apresenta importante papel na visão, atua na manutenção de tecidos epiteliais e imunidade",
      "assuntoPergunta": "saúde do trabalhador"
    }, {
      "questao": "Quais alimentos possuem uma maior concentração de vitamina D",
      "alternativas": [
        "Hortaliças de coloração verde-escuro; vegetais de coloração alaranjada",
        "Óleos vegetais; nozes; e sementes.",
        "Hortaliças verdes; também é produzida por bactérias presentes no intestino.",
        "Leite e derivados; salmão; e gemas de ovo."
      ],
      "respostaCorreta": "Leite e derivados; salmão; e gemas de ovo.",
      "assuntoPergunta": "saúde do trabalhador"
    }, {
      "questao": "Qual a importância da vitamina D ?",
      "alternativas": [
        "Apresenta importante papel na visão, atua na manutenção de tecidos epiteliais e imunidade.",
        "Atua como antioxidante",
        "Participa da absorção e utilização de dois sais importantes: o cálcio e o fósforo",
        "Possui importante papel na coagulação sanguínea."
      ],
      "respostaCorreta": "Participa da absorção e utilização de dois sais importantes: o cálcio e o fósforo",
      "assuntoPergunta": "saúde do trabalhador"
    }, {
      "questao": "O que a falta de vitamina A causa ao organismo ?",
      "alternativas": [
        "Raquitismo (problema de saúde que desencadeia amolecimento e fragilidade de ossos e, em crianças, causa deformações ósseas) e osteoporose",
        "Problemas no sistema nervoso",
        "Alterações na coagulação sanguínea",
        "Problemas de visão, alterações na pele e alteração na imunidade"
      ],
      "respostaCorreta": "Problemas de visão, alterações na pele e alteração na imunidade",
      "assuntoPergunta": "saúde do trabalhador"
    }, {
      "questao": " O que a falta de vitamina D causa ao organismo ?",
      "alternativas": [
        "Formigamentos, dormência e fadiga",
        "Raquitismo (problema de saúde que desencadeia amolecimento e fragilidade de ossos e, em crianças, causa deformações ósseas) e osteoporose",
        "Lesões gastrointestinais e na pele, e confusão mental",
        "Lesões na pele"
      ],
      "respostaCorreta": "Raquitismo (problema de saúde que desencadeia amolecimento e fragilidade de ossos e, em crianças, causa deformações ósseas) e osteoporose",
      "assuntoPergunta": "saúde do trabalhador"
    }, {
      "questao": "O que é desenvolvimento sustentável ?",
      "alternativas": [
        "Desenvolvimento sustentável significa suprir as necessidades dos indivíduos sem se importar com os efeitos que isso possa causar",
        "Desenvolvimento sustentável significa não utilizar itens de plástico",
        "Desenvolvimento sustentável significa suprir as necessidades do presente sem afetar a habilidade das gerações futuras de suprirem as próprias necessidades",
        "Desenvolvimento sustentável significa explorar o máximo que for possível"
      ],
      "respostaCorreta": "Desenvolvimento sustentável significa suprir as necessidades do presente sem afetar a habilidade das gerações futuras de suprirem as próprias necessidades",
      "assuntoPergunta": "sustentabilidade"
    }, {
      "questao": "Quanto tempo o tomate leva para poder ser cultivado ?",
      "alternativas": [
        "entre 90 e 110 dias",
        "entre 95 e 115 dias",
        "entre 200 e 250 dias",
        "entre 15 e 30 dias"
      ],
      "respostaCorreta": "entre 90 e 110 dias",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quanto tempo a batata leva para poder ser cultivada ?",
      "alternativas": [
        "entre 90 dias a 280 dias",
        "entre 15 dias a 20 dias",
        "entre 75 dias a 180 dias",
        "entre 65 dias a 700 dias"
      ],
      "respostaCorreta": "75 dias a 180 dias",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quanto tempo a mandioca leva para poder ser cultivada ?",
      "alternativas": [
        "entre 16 dias a 20 dias",
        "entre 7 meses a 5 anos",
        "entre 12 meses a 9 anos",
        "6 meses a 3 anos"
      ],
      "respostaCorreta": "6 meses a 3 anos",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quais as condições de temperatura ideal para o cultivo do morango ?",
      "alternativas": [
        "Temperaturas altas e calor",
        "Temperaturas altas e clima umido",
        "Baixas temperaturas e frio"
      ],
      "respostaCorreta": "Baixas temperaturas e frio",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quais os cuidados necessários para ter uma horta saudável",
      "alternativas": [
        "Utilizar pesticidas",
        "Regar excessivamente o solo",
        "Diversificar a plantação",
        "Matar todo e qualquet inseto"
      ],
      "respostaCorreta": "Diversificar a plantação",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Quais animais são benéficos para a horta ?",
      "alternativas": [
        "Abelhas",
        "Pulgões",
        "Lagartas",
        "Percevejos"
      ],
      "respostaCorreta": "Abelhas",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Por que é importante ter minhocas no solo ?",
      "alternativas": [
        "Devora as pragas",
        "Se alimenta de percevejos",
        "Não é importante, não causa danos e não trás benefícios",
        "Por se alimentar de restos orgânicos de animais e vegetais, suas fezes são transformadas em húmus"
      ],
      "respostaCorreta": "Por se alimentar de restos orgânicos de animais e vegetais, suas fezes são transformadas em húmus",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Por que é importante diversificar os cultivos?",
      "alternativas": [
        "Evitar a degradação do solo, aumenta a produtividade e reduz a ocorrência de pragas",
        "Produzir uma quantidade maior em menos tempo ",
        "Ajudar a aumentar degradação do solo",
        "Aumentar o uso de agrotóxicos"
      ],
      "respostaCorreta": "Evitar a degradação do solo, aumenta a produtividade e reduz a ocorrência de pragas",
      "assuntoPergunta": "cultivo"
    }, {
      "questao": "Qual a importância da prática de exercícios físicos e com que frequência ?",
      "alternativas": [
        "Estimular o sistema imunológico, ajuda a prevenir doenças cardíacas, moderam o colesterol",
        "Ficar em forma",
        "Não há importância, praticar exercícios é desnecessário",
        "É importante e o ideal é fazer a cada 60 dias"
      ],
      "respostaCorreta": "Estimular o sistema imunológico, ajuda a prevenir doenças cardíacas, moderam o colesterol",
      "assuntoPergunta": "saude do trabalhador"
    }, {
      "questao": "Quais os alimentos ajudam a diminuir o colesterol",
      "alternativas": [
        "Chocolate",
        "Beterraba",
        "Soja",
        "Alface"
      ],
      "respostaCorreta": "Soja",
      "assuntoPergunta": "saude do trabalhador"
    }]
  };

}


