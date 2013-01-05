//
//  PrincipalViewController.m
//  Acelerometro
//
//  Created by Rafael Brigagão Paulino on 10/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "PrincipalViewController.h"

@interface PrincipalViewController ()
{
    //interpretar as leituras do acelerometro e executar algo que quisermos
    CMMotionManager *gerenciadorMovimento;
    
    float velocidadeX;
    float velocidadeY;
    BOOL tocandoBola;
}

@end

@implementation PrincipalViewController

//metodo chamado quando uma view recebe um gesto de toque
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Toque comecou!");
    //recuperei uma instacia do toque feito
    UITouch *toqueTela = [touches anyObject];
    //descori onde o toque aconteceu
    CGPoint pontoTocado = [toqueTela locationInView:self.view];
    //comparar se o toque foi feito dentro do frame imagem bola
    if (CGRectContainsPoint(_bola.frame, pontoTocado)) {
        //se o ponto tocado estiver dentro do frame:
        tocandoBola = YES;
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Toque moveu!");
    
    UITouch *toqueTela = [touches anyObject];
    CGPoint novoPonto = [toqueTela locationInView:self.view];
    
    if (tocandoBola == YES) {
        _bola.center = novoPonto;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Toque acabou!");
    tocandoBola = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //inicaliazando o motion manager
    gerenciadorMovimento = [[CMMotionManager alloc] init];
    
    NSOperationQueue *filaProcessamento = [[NSOperationQueue alloc] init];
    
    [gerenciadorMovimento startDeviceMotionUpdatesToQueue:filaProcessamento withHandler:^(CMDeviceMotion *motion, NSError *error) {
        //o que vai ser executado para cada nova leitura do acelerometro na fila de processamento
        //THREAD SECUNDARIA
        
        //so posso deixar o acelerometro atuar se eu nao estiver tocando a bola
        if (tocandoBola == NO) {
            NSLog(@"X: %.2f - Y: %.2f - Z: %.2f", motion.gravity.x,motion.gravity.y,motion.gravity.z);
       
            //recaulculando a velocidade no eixo de acorod com a gravidade lida
            velocidadeX = velocidadeX + motion.gravity.x/5 + motion.userAcceleration.x;
            velocidadeY = velocidadeY + motion.gravity.y/5 + motion.userAcceleration.y;
            //motion.userAcceleration pega a aceleracao quando a pessoa mexe com o aparelho xaqualha
        
            //possiveis novos pontos
            float novoX = _bola.center.x + velocidadeX;
            float novoY = _bola.center.y - velocidadeY;
        
            //borda esquerda
            if (novoX - _bola.frame.size.width/2 < 0) {
                //passou dos limites
                //precisamos reajustar a direção da bola
                novoX = _bola.frame.size.width/2;
                velocidadeX = -velocidadeX * 0.8;
            }
        
            //borda direita
            if (novoX + _bola.frame.size.width/2 > 320) {
                //passou dos limites
                //precisamos reajustar a direção da bola
                novoX = 320 - _bola.frame.size.width/2;
                velocidadeX = -velocidadeX * 0.8;
            }
        
            //borda superior
            if (novoY - _bola.frame.size.height/2 < 0) {
                //passou dos limites
                //precisamos reajustar a direção da bola
                novoY = _bola.frame.size.height/2;
                velocidadeY = -velocidadeY * 0.8;
            }
        
            //borda inferior
            if (novoY + _bola.frame.size.height/2 > 460) {
                //passou dos limites
                //precisamos reajustar a direção da bola
                novoY = 460 - _bola.frame.size.height/2;
                velocidadeY = -velocidadeY * 0.8;
            }
        
            //temos certeza que o novoX e o novoY esta no limites da tela, podemos alterar a posicao da bola com seguranca
            //tudo que fizemos neste bloco esta acontecendo numa thread secundaria
            //IMPORTANTE qualquer alteracao em um componente visual dem sua interfa so pode acontece na main thread
            //precisamos encontrar uma maneira para recuperar a atencao da main thread e pedir a alteracao da posicao da imagem da bola
            //dispara um processo Na thread mae
            dispatch_async(dispatch_get_main_queue(), ^{
                _bola.center = CGPointMake(novoX, novoY);
            });
        }
        
        
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//controla se a tela gira
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //so funciona agora com o modo retrato
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
