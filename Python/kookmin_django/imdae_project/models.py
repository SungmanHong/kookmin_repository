# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from __future__ import unicode_literals

from django.db import models


class LeaseData(models.Model):
    seq_num = models.AutoField(db_column='SEQ_NUM', primary_key=True)  # Field name made lowercase.
    seq_field = models.IntegerField(db_column='SEQ_', blank=True, null=True)  # Field name made lowercase. Field renamed because it ended with '_'.
    block_nm = models.CharField(db_column='BLOCK_NM', max_length=10, blank=True, null=True)  # Field name made lowercase.
    regnum_block = models.CharField(db_column='REGNUM_BLOCK', max_length=30, blank=True, null=True)  # Field name made lowercase.
    a_4 = models.CharField(db_column='A_4', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_5 = models.CharField(db_column='A_5', max_length=20, blank=True, null=True)  # Field name made lowercase.
    a_6 = models.CharField(db_column='A_6', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_7 = models.CharField(db_column='A_7', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_8 = models.CharField(db_column='A_8', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_9 = models.CharField(db_column='A_9', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_10 = models.CharField(db_column='A_10', max_length=20, blank=True, null=True)  # Field name made lowercase.
    a_11 = models.CharField(db_column='A_11', max_length=30, blank=True, null=True)  # Field name made lowercase.
    a_12 = models.CharField(db_column='A_12', max_length=30, blank=True, null=True)  # Field name made lowercase.
    a_13 = models.CharField(db_column='A_13', max_length=20, blank=True, null=True)  # Field name made lowercase.
    a_14 = models.CharField(db_column='A_14', max_length=20, blank=True, null=True)  # Field name made lowercase.
    a_15 = models.CharField(db_column='A_15', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_16 = models.CharField(db_column='A_16', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_17 = models.CharField(db_column='A_17', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_18 = models.CharField(db_column='A_18', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_19 = models.CharField(db_column='A_19', max_length=100, blank=True, null=True)  # Field name made lowercase.
    a_20 = models.DateField(db_column='A_20', blank=True, null=True)  # Field name made lowercase.
    a_21 = models.DateField(db_column='A_21', blank=True, null=True)  # Field name made lowercase.
    a_22 = models.IntegerField(db_column='A_22', blank=True, null=True)  # Field name made lowercase.
    a_23 = models.CharField(db_column='A_23', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_24 = models.CharField(db_column='A_24', max_length=20, blank=True, null=True)  # Field name made lowercase.
    a_25 = models.CharField(db_column='A_25', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_26 = models.CharField(db_column='A_26', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_27 = models.CharField(db_column='A_27', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_28 = models.CharField(db_column='A_28', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_29 = models.CharField(db_column='A_29', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_30 = models.CharField(db_column='A_30', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_31 = models.IntegerField(db_column='A_31', blank=True, null=True)  # Field name made lowercase.
    a_32 = models.CharField(db_column='A_32', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_33 = models.CharField(db_column='A_33', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_34 = models.IntegerField(db_column='A_34', blank=True, null=True)  # Field name made lowercase.
    a_35 = models.IntegerField(db_column='A_35', blank=True, null=True)  # Field name made lowercase.
    a_36 = models.CharField(db_column='A_36', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_37 = models.IntegerField(db_column='A_37', blank=True, null=True)  # Field name made lowercase.
    a_38 = models.CharField(db_column='A_38', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_39 = models.CharField(db_column='A_39', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_40 = models.CharField(db_column='A_40', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_41 = models.CharField(db_column='A_41', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_42 = models.CharField(db_column='A_42', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_43 = models.CharField(db_column='A_43', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_44 = models.CharField(db_column='A_44', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_45 = models.CharField(db_column='A_45', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_46 = models.IntegerField(db_column='A_46', blank=True, null=True)  # Field name made lowercase.
    a_47 = models.IntegerField(db_column='A_47', blank=True, null=True)  # Field name made lowercase.
    a_48 = models.IntegerField(db_column='A_48', blank=True, null=True)  # Field name made lowercase.
    a_49 = models.CharField(db_column='A_49', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_50 = models.IntegerField(db_column='A_50', blank=True, null=True)  # Field name made lowercase.
    a_51 = models.DateField(db_column='A_51', blank=True, null=True)  # Field name made lowercase.
    a_52 = models.CharField(db_column='A_52', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_53 = models.IntegerField(db_column='A_53', blank=True, null=True)  # Field name made lowercase.
    a_54 = models.CharField(db_column='A_54', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_55 = models.CharField(db_column='A_55', max_length=10, blank=True, null=True)  # Field name made lowercase.
    a_56 = models.CharField(db_column='A_56', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_57 = models.CharField(db_column='A_57', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_58 = models.CharField(db_column='A_58', max_length=5, blank=True, null=True)  # Field name made lowercase.
    a_59 = models.CharField(db_column='A_59', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_1 = models.CharField(db_column='W_1', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_2 = models.CharField(db_column='W_2', max_length=50, blank=True, null=True)  # Field name made lowercase.
    w_3 = models.CharField(db_column='W_3', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_4 = models.CharField(db_column='W_4', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_5 = models.CharField(db_column='W_5', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_6 = models.IntegerField(db_column='W_6', blank=True, null=True)  # Field name made lowercase.
    w_7 = models.IntegerField(db_column='W_7', blank=True, null=True)  # Field name made lowercase.
    w_8 = models.CharField(db_column='W_8', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_9 = models.CharField(db_column='W_9', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_10 = models.IntegerField(db_column='W_10', blank=True, null=True)  # Field name made lowercase.
    w_11 = models.IntegerField(db_column='W_11', blank=True, null=True)  # Field name made lowercase.
    w_12 = models.CharField(db_column='W_12', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_13 = models.CharField(db_column='W_13', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_14 = models.CharField(db_column='W_14', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_15 = models.CharField(db_column='W_15', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_16 = models.CharField(db_column='W_16', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_17 = models.IntegerField(db_column='W_17', blank=True, null=True)  # Field name made lowercase.
    w_18 = models.CharField(db_column='W_18', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_19 = models.IntegerField(db_column='W_19', blank=True, null=True)  # Field name made lowercase.
    w_20 = models.IntegerField(db_column='W_20', blank=True, null=True)  # Field name made lowercase.
    w_21 = models.IntegerField(db_column='W_21', blank=True, null=True)  # Field name made lowercase.
    w_22 = models.IntegerField(db_column='W_22', blank=True, null=True)  # Field name made lowercase.
    w_23 = models.IntegerField(db_column='W_23', blank=True, null=True)  # Field name made lowercase.
    w_24 = models.IntegerField(db_column='W_24', blank=True, null=True)  # Field name made lowercase.
    w_25 = models.IntegerField(db_column='W_25', blank=True, null=True)  # Field name made lowercase.
    w_26 = models.DateField(db_column='W_26', blank=True, null=True)  # Field name made lowercase.
    w_27 = models.CharField(db_column='W_27', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_28 = models.IntegerField(db_column='W_28', blank=True, null=True)  # Field name made lowercase.
    w_29 = models.IntegerField(db_column='W_29', blank=True, null=True)  # Field name made lowercase.
    w_30 = models.CharField(db_column='W_30', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_31 = models.CharField(db_column='W_31', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_32 = models.CharField(db_column='W_32', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_33 = models.CharField(db_column='W_33', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_34 = models.CharField(db_column='W_34', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_35 = models.CharField(db_column='W_35', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_36 = models.CharField(db_column='W_36', max_length=5, blank=True, null=True)  # Field name made lowercase.
    w_37 = models.DateField(db_column='W_37', blank=True, null=True)  # Field name made lowercase.
    w_38 = models.CharField(db_column='W_38', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_39 = models.CharField(db_column='W_39', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_40 = models.CharField(db_column='W_40', max_length=10, blank=True, null=True)  # Field name made lowercase.
    w_41 = models.IntegerField(db_column='W_41', blank=True, null=True)  # Field name made lowercase.
    w_42 = models.IntegerField(db_column='W_42', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'LEASE_DATA'
