#!/usr/bin/perl -w

use lib '../src/bioperl-1.6.924';
use lib '../src/ensembl/modules';
use lib '../src/ensembl/modules/Bio/EnsEMBL/DBSQL';
use lib '../src/ensembl-compara/modules';
use lib '../src/ensembl-variation/modules';
use lib '../src/ensembl-funcgen/modules';
use strict;
use Tk;
use utf8;
use warnings;
use Switch;
use Term::ANSIColor;

#Cargar modulos requeridos API
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Variation::DBSQL::DBAdaptor;
use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::DBSQL::SliceAdaptor;
use Bio::EnsEMBL::Variation::VariationFeature;
use Bio::EnsEMBL::DBSQL::GeneAdaptor;
use Bio::EnsEMBL::Registry;

my $ver = "2.0.0";


#Global variables

my $stablished_MAF=0.0001;
my $registryVariation = 'Bio::EnsEMBL::Registry';

#########################     MAIN MENU      #########################

my $mw = MainWindow->new;
$mw->geometry("1200x565");
$mw->title("PolyPrimer");


my $main_menu = $mw->Menu(-background =>'CadetBlue');
$mw->configure(-menu => $main_menu);

my $file_menu = $main_menu->cascade(-label=>"File", -underline => 0, -tearoff=>0);
$file_menu->command(-label=>"Exit", -underline=>0, -command => sub{exit});

my $ayuda = $main_menu->cascade(-label => "Help", -underline => 0, -tearoff => 0);
$ayuda->command(-label => "Version", -underline => 0,
                    -command => sub{$mw->messageBox(-message => "$ver",
                                                    -type => "ok", -title=>"Version")});
$ayuda->command(-label => "About", -underline => 0, -command => \&show_about);


## OUTPUT FRAME ##

my $output_frame = $mw->Frame(-relief => 'raised', -borderwidth => 5)->pack(-side => "right", -fill=> "x");
my $maf_frame =$output_frame->Frame(-relief => 'raised', -borderwidth => 10)->pack(-side=>"top", -fill=>"x");
my $maf_label = $maf_frame->Label(-text=>"\tMinimum MAF value: ")->pack(-side=>"left", -fill=>"y");
my $maf_entry = $maf_frame->Entry(-background=>"white", -text=>$stablished_MAF)->pack(-fill=>"x", -side=>"left");
my $maf_button = $maf_frame->Button(-text => "Select", -command => \&modify_maf)->pack(-fill=>"y", -side=>"left");
my $output_scroll = $output_frame->Scrollbar();
my $output_text = $output_frame->Text(-yscrollcommand => ['set', $output_scroll], -background=>"white");

$output_scroll->configure(-command => ['yview', $output_text]);

$output_scroll->pack(-side => "right", -expand => "no", -fill => "y");
$output_text->pack(-ipadx=>100,-ipady=>220 );

##################

## PRIMER FRAME ##

#Primer variables

my @fwdprimers;
my @rvsprimers;

my @fwdprimer_entry;
my @rvsprimer_entry;


my $gene_frame= $mw->Frame(-relief => 'raised', -borderwidth => 5)->pack(-side => "top", -fill => "x");
$gene_frame->Label(-text=>"Gene (HGNC name)")->pack(-side=>"top");
my $gene_entry= $gene_frame->Entry(-background=>"white", -justify=>"center")->pack(-fill=>"x");

my $left_frame= $mw->Frame(-relief => 'raised', -borderwidth => 5)->pack(-side => "top", -fill => "x");
my $primers_info_frame = $left_frame->Frame(-borderwidth => 5)->pack(-side => "left", -fill =>"y");
my $primers_entry_frame = $left_frame->Frame(-borderwidth => 5)->pack(-side => "right", -fill =>"y");

#Pair 1

$primers_entry_frame->Label(-text => "Pair 1")->pack(-fill =>"x");
$primers_info_frame->Label(-text => "")->pack(-fill =>"x");

$fwdprimer_entry[0]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Forward Primer")->pack(-fill =>"x");

$rvsprimer_entry[0]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Reverse Primer")->pack(-fill =>"x");

$primers_info_frame->Label(-text => "")->pack(-fill =>"x");
$primers_entry_frame->Label(-text => "")->pack(-fill =>"x");

#Pair 2

$primers_entry_frame->Label(-text => "Pair 2")->pack(-fill =>"x");
$primers_info_frame->Label(-text => "")->pack(-fill =>"x");

$fwdprimer_entry[1]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Forward Primer")->pack(-fill =>"x");

$rvsprimer_entry[1]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Reverse Primer")->pack(-fill =>"x");

$primers_info_frame->Label(-text => "")->pack(-fill =>"x");
$primers_entry_frame->Label(-text => "")->pack(-fill =>"x");



#Pair 3

$primers_entry_frame->Label(-text => "Pair 3")->pack(-fill =>"x");
$primers_info_frame->Label(-text => "")->pack(-fill =>"x");

$fwdprimer_entry[2]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Forward Primer")->pack(-fill =>"x");

$rvsprimer_entry[2]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Reverse Primer")->pack(-fill =>"x");

$primers_info_frame->Label(-text => "")->pack(-fill =>"x");
$primers_entry_frame->Label(-text => "")->pack(-fill =>"x");

#Truqui para diseño
$primers_info_frame->Label(-text => "")->pack(-fill =>"x");

#Pair 4

$primers_entry_frame->Label(-text => "Pair 4")->pack(-fill =>"x");
$primers_info_frame->Label(-text => "")->pack(-fill =>"x");

$fwdprimer_entry[3]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Forward Primer")->pack(-fill =>"x");

$rvsprimer_entry[3]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Reverse Primer")->pack(-fill =>"x");

$primers_info_frame->Label(-text => "")->pack(-fill =>"x");
$primers_entry_frame->Label(-text => "")->pack(-fill =>"x");





#Pair 5

$primers_entry_frame->Label(-text => "Pair 5")->pack(-fill =>"x");
$primers_info_frame->Label(-text => "")->pack(-fill =>"x");

$fwdprimer_entry[4]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Forward Primer")->pack(-fill =>"x");

$rvsprimer_entry[4]= $primers_entry_frame->Entry(-background=>"white")->pack(-fill =>"x", -ipadx=>100);
$primers_info_frame->Label(-text => "Reverse Primer")->pack(-fill =>"x");

$primers_info_frame->Label(-text => "")->pack(-fill =>"x");
$primers_entry_frame->Label(-text => "")->pack(-fill =>"x");

my $boton= $primers_entry_frame->Button(-text => "Enter", -command => \&activate_check)->pack(-fill =>"x");

##################

MainLoop;

##########################################################################

#########################     SUBROUTINES      #########################

sub update_output {

    my $output=$_[0];
    $output_text->delete('0.0', 'end');
    $output_text->insert("end", $output);


}

sub show_about {
    my $help_win = $mw->Toplevel;
    $help_win->geometry("300x50");
    $help_win->title("About");

    my $help_msg = "Check if your primers contain any polymorphisms";
    $help_win->Label(-text => $help_msg)->pack();
    $help_win->Button(-text => "Ok", -command => [$help_win => 'destroy'])->pack();
}

## Variables for working qith primers and sequences ##

my $fwdprimer_startposition;
my $fwdprimer_endposition;
my $rvsprimer_startposition;
my $rvsprimer_endposition;

my $fwdprimer_variationinfo;
my $rvsprimer_variationinfo;

my $fwdprimerSNPpositions;
my $rvsprimerSNPpositions;

my $rvsprimer_rcomp;

sub activate_check {

    get_primers();

    my $output="";
    my $GeneName= $gene_entry->get();
    if (($GeneName eq "")||($GeneName eq " "))
    {
        $output= "No gene was entered";
        update_output($output);
    }
    else
    {
        #Conexion a la base de datos de variaciones
        $registryVariation->load_registry_from_db(
          -host => 'ensembldb.ensembl.org',
          -user => 'anonymous',
          -port => 3337,
        );

        #Cargar adaptadores necesarios
        my $gene_adaptor = $registryVariation->get_adaptor('human', 'core', 'gene');
        my $slice_adaptor = $registryVariation->get_adaptor('human', 'core', 'slice');
        my $vf_adaptor = $registryVariation->get_adaptor('human', 'variation', 'variationfeature');

        my @genes = @{ $gene_adaptor->fetch_all_by_external_name($GeneName) };

        if ($genes[0])
        {
            foreach my $gene (@genes)
            {
                my $id = $gene->stable_id;
                my $slice = $slice_adaptor->fetch_by_gene_stable_id($id, 0);
                my $secuencia = $slice -> seq();

                $output=$output . "Gene $id ($GeneName)\n\n";

                my $counter=0;
                while ($counter<5){

                    $fwdprimer_startposition=undef;
                    $fwdprimer_endposition=undef;
                    $rvsprimer_startposition=undef;
                    $rvsprimer_endposition=undef;

                    $fwdprimer_variationinfo='';
                    $rvsprimer_variationinfo='';

                    $fwdprimerSNPpositions=CreateReference($fwdprimers[$counter]);
                    $rvsprimerSNPpositions=CreateReference($rvsprimers[$counter]);

                    $rvsprimer_rcomp = reverse_complementary($rvsprimers[$counter]);



                    locate_primer ($secuencia, $fwdprimers[$counter], 'fwd');
                    locate_primer ($secuencia, $rvsprimer_rcomp, 'rvs');

                    if (($fwdprimer_startposition ne -1)||($rvsprimer_startposition ne -1)&&(($fwdprimer_startposition ne $fwdprimer_endposition)&&($rvsprimer_startposition ne $rvsprimer_endposition)))
                    {
                        SNPList($slice, $vf_adaptor, $counter);
                    }
                    my $number=$counter+1;

                    if (($fwdprimer_startposition ne -1)&&($fwdprimer_startposition ne $fwdprimer_endposition))
                    {
                        $output=$output . "->Pair $number\nForward: $fwdprimers[$counter]\n$fwdprimerSNPpositions\n$fwdprimer_startposition - $fwdprimer_endposition\n$fwdprimer_variationinfo\n";
                    }
                    else
                    {
                        if (($fwdprimers[$counter])&&($fwdprimers[$counter] ne " "))
                        {
                            $output=$output . "->Pair $number\nForward: Not found in sequence\n\n";
                        }
                        else {$output=$output . "->Pair $number\nForward: Not available\n";}
                    }
                    if (($rvsprimer_startposition ne -1)&&($rvsprimer_startposition ne $rvsprimer_endposition))
                    {
                        $output=$output . "Reverse: $rvsprimers[$counter]\n$rvsprimerSNPpositions\n$rvsprimer_startposition - $rvsprimer_endposition\n$rvsprimer_variationinfo\n\n";
                    }
                    else
                    {
                        if (($rvsprimers[$counter])&&($rvsprimers[$counter] ne " "))
                        {
                            $output=$output . "Reverse: Not found in sequence\n\n";
                        }
                        else {$output=$output . "Reverse: Not available\n\n";}
                    }
                    update_output ($output);
                    $counter++;
                }
            }
        }
        else { $output = "No genes found with HGNC $GeneName"; update_output ($output); }
    }
}

sub get_primers
{
    $fwdprimers[0] = uc trim($fwdprimer_entry[0]->get());
    $fwdprimers[1] = uc trim($fwdprimer_entry[1]->get());
    $fwdprimers[2] = uc trim($fwdprimer_entry[2]->get());
    $fwdprimers[3] = uc trim($fwdprimer_entry[3]->get());
    $fwdprimers[4] = uc trim($fwdprimer_entry[4]->get());

    $rvsprimers[0] = uc trim($rvsprimer_entry[0]->get());
    $rvsprimers[1] = uc trim($rvsprimer_entry[1]->get());
    $rvsprimers[2] = uc trim($rvsprimer_entry[2]->get());
    $rvsprimers[3] = uc trim($rvsprimer_entry[3]->get());
    $rvsprimers[4] = uc trim($rvsprimer_entry[4]->get());
}

sub locate_primer
{


    my $found = 0;

    my $secuencia = $_[0];
    my $fwdprimer = $_[1];

    my $posicionseq = 0;
    my $posicionprimer = 0;

    while (($found == 0) && ($posicionseq < length($secuencia)))
    {

        my $baseprimer = substr ($fwdprimer, 0, 1);
        my $basesecuencia = substr ($secuencia, $posicionseq, 1);
        if ($basesecuencia eq $baseprimer)
        {
            my $posicionseqauxiliar = $posicionseq + 1;
            $posicionprimer = $posicionprimer + 1;
            $basesecuencia = substr ($secuencia, $posicionseqauxiliar, 1);
            $baseprimer = substr ($fwdprimer, $posicionprimer, 1);
            while (( $baseprimer eq $basesecuencia) && ($posicionprimer < length ($fwdprimer)) && ($posicionseqauxiliar < length ($secuencia)))
            {
                $posicionseqauxiliar = $posicionseqauxiliar + 1;
                $posicionprimer = $posicionprimer + 1;
                $basesecuencia = substr ($secuencia, $posicionseqauxiliar, 1);
                $baseprimer = substr ($fwdprimer, $posicionprimer, 1);
            }
            if ( $posicionprimer == (length ($fwdprimer))) { $found = 1; }
            else { $posicionprimer = 0; }
        }
        $posicionseq=$posicionseq+1;
    }

    if ($found eq 0)
    {
        if ($_[2] eq 'fwd') { $fwdprimer_startposition = 0; $fwdprimer_endposition = 0; }
        if ($_[2] eq 'rvs') { $rvsprimer_startposition = 0; $rvsprimer_endposition = 0; }

    }
    else
    {
        my $posicionfinal=$posicionseq + length ($fwdprimer) - 1;
        if ($_[2] eq 'fwd'){ $fwdprimer_startposition = $posicionseq; $fwdprimer_endposition = $posicionfinal; }
        if ($_[2] eq 'rvs'){ $rvsprimer_startposition = $posicionseq; $rvsprimer_endposition = $posicionfinal; }
    }

}

sub reverse_complementary {

    my $rvsprimer=$_[0];
    my $a=length($rvsprimer)-1;
    my $rvsprimer_rcomp='';
    my $newchar_r='x';
    while ($a>=0)
    {
        my $newchar= substr($rvsprimer, $a, 1);
        switch ($newchar)
        {
            case 'A' {$newchar_r='T'}
            case 'T' {$newchar_r='A'}
            case 'C' {$newchar_r='G'}
            case 'G' {$newchar_r='C'}
        }
        $rvsprimer_rcomp=$rvsprimer_rcomp . "$newchar_r";
        --$a;
    }
    return $rvsprimer_rcomp;

}

sub SNPList
{

    my $slice= $_[0];
    my $vf_adaptor=$_[1];
    my $rvsprimer=$rvsprimers[$_[2]];
    my $append='';

    my $vfs  = $vf_adaptor->fetch_all_by_Slice($slice);
    foreach my $vf (@{$vfs}){


        my $allelestart=$vf->start();
        my $alleleend=$vf->end();

        my $MAF_value=$vf->minor_allele_frequency();
        if ($MAF_value){
            if ($MAF_value>$stablished_MAF)
            {
                my $primerposition='';

                #Forward primer info update.
                if ((($allelestart>$fwdprimer_startposition)&&($allelestart<$fwdprimer_endposition))||(($alleleend>$fwdprimer_startposition)&&($alleleend<$fwdprimer_endposition)))
                {
                    $primerposition=$allelestart-$fwdprimer_startposition+1;
                    $append= "Variation: ".$vf->variation_name." with alleles " . $vf->allele_string." on nucleotide ".$primerposition." and MAF ".$MAF_value ."\n";
                    $fwdprimer_variationinfo=$fwdprimer_variationinfo . $append;
                    substr($fwdprimerSNPpositions, ($primerposition+8), 1)='^';
                }
                #Reverse primer info update.
                if ((($allelestart>$rvsprimer_startposition)&&($allelestart<$rvsprimer_endposition))||(($alleleend>$rvsprimer_startposition)&&($alleleend<$rvsprimer_endposition)))
                {
                    $primerposition=(length($rvsprimer))-($allelestart-$rvsprimer_startposition);
                    $append="Variation: ".$vf->variation_name." with alleles " . $vf->allele_string." (on forward strand) on nucleotide ".$primerposition." and MAF ".$MAF_value ."\n";
                    $rvsprimer_variationinfo= $append . $rvsprimer_variationinfo;
                    substr($rvsprimerSNPpositions, ($primerposition+8), 1)='^';
                }
            }
        }
    }
}

sub CreateReference
{

    my $reference="         ";
    my $i=0;
    while ($i<length($_[0]))
    {
        $reference=$reference.'.';
        ++$i;
    }
    return $reference;
}

sub print_primers
{

    my $GeneName=$_[0];
    my $output="Gene: $GeneName\n
        Pair 1:\nForward: $fwdprimers[0]\nReverse: $rvsprimers[0]\n
        Pair 2:\nForward: $fwdprimers[1]\nReverse: $rvsprimers[1]\n
        Pair 3:\nForward: $fwdprimers[2]\nReverse: $rvsprimers[2]\n
        Pair 4:\nForward: $fwdprimers[3]\nReverse: $rvsprimers[3]\n
        Pair 5:\nForward: $fwdprimers[4]\nReverse: $rvsprimers[4]\n";

    update_output($output);

}

sub  trim
{

    my $s = $_[0];
    $s =~ s/^\s+//;
    $s =~ s/\s+$//;
    return $s
};

sub modify_maf
{

    $stablished_MAF=$maf_entry->get();
}

###########################################################################
