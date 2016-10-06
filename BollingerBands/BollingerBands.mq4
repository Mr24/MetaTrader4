//+------------------------------------------------------------------+
//|                      VerysVeryInc.MetaTrader4.BollingerBands.mq4 |
//|                  Copyright(c) 2016, VerysVery Inc. & Yoshio.Mr24 |
//|                             https://github.com/Mr24/MetaTrader4/ |
//|                                                 Since:2016.09.24 |
//|                                                            &     |
//|                                                        Bands.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//|                                Released under the Apache license |
//|			              https://opensource.org/licenses/Apache-2.0 |
//+------------------------------------------------------------------+
#property copyright "Copyright(c) 2016 -, VerysVery Inc. && Yoshio.Mr24"
#property link      "https://github.com/Mr24/MetaTrader4/"
#property description "VsV.MT4.BollingerBands - Ver.1.0.0 Update:2016.10.05"
#property strict

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Gold
#property indicator_color2 Gold
#property indicator_color3 Gold

//--- indicator parameters
input int    InpBandsPeriod=20;      // Bands Period
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=2.0; // Bands Deviations

//--- Indicator buffer
double ExtMovingBuffer[];
double ExtUpperBuffer[];
double ExtLowerBuffer[];
double ExtStdDevBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{
//--- 1 additional buffer used for counting.
  	IndicatorBuffers(4);
   	IndicatorDigits(Digits);

//*--- middle line
   	SetIndexStyle(0,DRAW_LINE);
   	SetIndexBuffer(0,ExtMovingBuffer);
   	SetIndexShift(0,InpBandsShift);
   	SetIndexLabel(0,"BB SMA");
//*--- upper band
   	SetIndexStyle(1,DRAW_LINE);
   	SetIndexBuffer(1,ExtUpperBuffer);
   	SetIndexShift(1,InpBandsShift);
   	SetIndexLabel(1,"BB Upper");
//*--- lower band
   	SetIndexStyle(2,DRAW_LINE);
   	SetIndexBuffer(2,ExtLowerBuffer);
   	SetIndexShift(2,InpBandsShift);
   	SetIndexLabel(2,"BB Lower");

//--- work buffer
   	SetIndexBuffer(3,ExtStdDevBuffer);

//--- check for input parameter
   	if(InpBandsPeriod<=0)
   	{
    	Print("Wrong input parameter Bands Period=",InpBandsPeriod);
      	return(INIT_FAILED);
    }
//---
   	SetIndexDrawBegin(0,InpBandsPeriod+InpBandsShift);
   	SetIndexDrawBegin(1,InpBandsPeriod+InpBandsShift);
   	SetIndexDrawBegin(2,InpBandsPeriod+InpBandsShift);
//--- initialization done
   return(INIT_SUCCEEDED);
}
//***//


//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,		//* Each rate the Number of elements
                const int prev_calculated,	//* Computed the Number of elements
            	const datetime &time[],		//* The Time sequence of each
                const double &open[],		//* Open Price Array
                const double &high[],		//* High Price Array
                const double &low[],		//* Lows Price Array
                const double &close[],		//* Close Price Array
                const long &tick_volume[],	//* Tick Count
                const long &volume[],		//* The Real Volume
                const int &spread[])		//* Spread
{
   	int i,pos;

//--- Check for Bars Count
   	if(rates_total<=InpBandsPeriod || InpBandsPeriod<=0)
    	return(0);

//--- counting from 0 to rates_total
   	ArraySetAsSeries(ExtMovingBuffer,false);
   	ArraySetAsSeries(ExtUpperBuffer,false);
   	ArraySetAsSeries(ExtLowerBuffer,false);
   	ArraySetAsSeries(ExtStdDevBuffer,false);
   	ArraySetAsSeries(close,false);

//--- initial zero
	if(prev_calculated<1)
    {
    	for(i=0; i<InpBandsPeriod; i++)
        {
        	ExtMovingBuffer[i]=EMPTY_VALUE;
        	ExtUpperBuffer[i]=EMPTY_VALUE;
        	ExtLowerBuffer[i]=EMPTY_VALUE;
        }
    }

//--- starting calculation
	if(prev_calculated>1)
    	pos=prev_calculated-1;
   	else
     	pos=0;

//--- main cycle
   	for(i=pos; i<rates_total && !IsStopped(); i++)
    {
    //--- middle line
    	ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,close);

    //--- calculate and write down StdDev
     	ExtStdDevBuffer[i]=StdDev_Func(i,close,ExtMovingBuffer,InpBandsPeriod);

    //--- upper line
    	ExtUpperBuffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*ExtStdDevBuffer[i];
   	//--- lower line
    	ExtLowerBuffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*ExtStdDevBuffer[i];

    }
//---- OnCalculate done. Return new prev_calculated.
  	return(rates_total);
}
//***//


//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
{
//--- variables
	double StdDev_dTmp=0.0;

//--- check for position
	if(position>=period)
    {
    	//--- calcualte StdDev
      		for(int i=0; i<period; i++)
         	StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);

		StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
    }

//--- return calculated value
  	return(StdDev_dTmp);
}

//+------------------------------------------------------------------+